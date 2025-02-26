{ lib, pkgs, inputs, config, ... }:

{
  imports = [
    inputs.microvm.nixosModules.microvm
  ];

  options.vm = {

    build = {
      initrd = lib.mkOption {
        type = lib.types.path;
        default = "${config.system.build.initialRamdisk}/${config.system.boot.loader.initrdFile}";
      };
      kernel = lib.mkOption {
        type = lib.types.path;
        default = config.boot.kernelPackages.kernel;
      };
    };

    contain = lib.mkOption {
      type = lib.types.package;
      default = (pkgs.runCommand "contain" {
        buildInputs = [ pkgs.makeWrapper ];
      } ''
        makeWrapper ${pkgs.contain}/bin/contain $out/bin/contain --set PATH ${lib.makeBinPath (with pkgs; [ cloud-hypervisor-graphics virtiofsd crosvm ])}
      '');
    };

    containConfig = lib.mkOption
    (
      let
        json = pkgs.formats.json {};
        conf = {
          initrd_path = config.vm.build.initrd;
          kernel_path = "${config.vm.build.kernel.dev}/vmlinux";
          cmdline = "reboot=t panic=-1 root=fstab loglevel=4 init=${config.system.build.toplevel}/init regInfo=${pkgs.closureInfo {rootPaths = [ config.system.build.toplevel ];}}/registration";
          cpu = {
            cores = 16;
          };
          memory = {
            size = 16384;
          };
          filesystem = {
            shares = [
              {
                tag = "nix-store-ro";
                source = "/nix/store";
                write = false;
              }
              {
                tag = "workspace-rw";
                source = "$pwd";
                write = true;
              }
            ];
          };
          network = {
            assign_tap_device = true;
          };
          graphics = {
            virtio_gpu = true;
          };
        };
      in
      {
          type = lib.types.path;
          default = json.generate "contain-dev-vm-config.json" conf;
      }
    );

    run = lib.mkOption (
      {
        type = lib.types.package;
        default = pkgs.nu.writeScriptBin "vm" ''
          let workspace_dir = $"(pwd)/workspace"
          try { md vm }
          cd vm
          try { rm -r ./* }
          open ${config.vm.containConfig} --raw | str replace "$pwd" $workspace_dir | save contain-config.json
          ${config.vm.contain}/bin/contain start contain-config.json
        '';
      }
    );
  };

  config = {
    microvm = {
      graphics.enable = true;
      hypervisor = "cloud-hypervisor";
      writableStoreOverlay = "/nix/.rw-store";
      mem = 16384;
      vcpu = 28;
      # volumes = [ {
      #   image = "nix-store-rw-overlay.img";
      #   mountPoint = "/nix/.rw-store";
      #   size = 2048;
      # } ];
      shares = [
        {
          proto = "virtiofs";
          tag = "nix-store-ro";
          source = "/nix/store";
          mountPoint = "/nix/.ro-store";
        }
        {
          proto = "virtiofs";
          tag = "workspace-rw";
          source = "null";
          mountPoint = "/home/timon/workspace";
        }
      ];
    };

    systemd.services.logrotate-checkconf.enable = false;
    users.users.root.password = "root";

    networking.firewall.enable = false;

    boot.kernelPatches = lib.singleton {
      name = "disable-drm-fbdev-emulation";
      patch = null;
      extraConfig = ''
        DRM_FBDEV_EMULATION n
      '';
    };

    environment.sessionVariables = {
      WAYLAND_DISPLAY = "wayland-1";
      DISPLAY = ":0";
      GDK_BACKEND = "wayland";
      XDG_SESSION_TYPE = "wayland";
      SDL_VIDEODRIVER = "wayland";
      CLUTTER_BACKEND = "wayland";
    };

    systemd.user.services = {
      wayland-proxy = {
        enable = true;
        description = "wayland proxy";
        serviceConfig = {
          ExecStart = "${pkgs.wayland-proxy-virtwl}/bin/wayland-proxy-virtwl --virtio-gpu --tag='[vm] - ' --x-display=0 --xwayland-binary=${pkgs.xwayland}/bin/Xwayland";
          Restart = "on-failure";
          RestartSec = 5;
        };
        wantedBy = [ "default.target" ];
      };
      main-terminal = {
        enable = true;
        description = "main-terminal";
        serviceConfig =
          let
            runMainTerminalScript = pkgs.writeScript "run-main-terminal" ''
              . "/etc/profiles/per-user/$USER/etc/profile.d/hm-session-vars.sh"
              export PATH="/run/wrappers/bin:$HOME/.nix-profile/bin:/nix/profile/bin:$HOME/.local/state/nix/profile/bin:/etc/profiles/per-user/$USER/bin:/nix/var/nix/profiles/default/bin:/run/current-system/sw/bin"
              ${pkgs.nushell}/bin/nu --login -e "cd ~/workspace"
            '';
          in
          {
            ExecStart = "${pkgs.wayland-proxy-virtwl}/bin/wayland-proxy-virtwl --virtio-gpu --tag='[vm] - ' --wayland-display wayland-main-terminal -- ${pkgs.rio}/bin/rio -e ${runMainTerminalScript}";
            Restart = "always";
            StartLimitInterval = 0;
          };
        wantedBy = [ "default.target" ];
      };
    };

    environment.systemPackages = [
      (pkgs.nu.writeScriptBin "run-sommelier" ''
        def --wrapped main [...args] {
          ${pkgs.sommelier}/bin/sommelier --virtgpu-channel ...$args
        }
      '')
      (pkgs.nu.writeScriptBin "stop" ''poweroff'')

      pkgs.gcc
      (
        let
          rustConfig = {
            extensions = [
              "rust-src"
              "rust-analyzer"
            ];
            targets = [
              "x86_64-unknown-linux-gnu"
            ];
          };
        in
        pkgs.rust-bin.stable.latest.default.override rustConfig
      )
    ];

    nixpkgs.overlays = [
      (self: super:
        let
          overlay = super.fetchFromGitHub {
            repo = "rust-overlay";
            owner = "oxalica";
            rev = "6e6ae2acf4221380140c22d65b6c41f4726f5932";
            sha256 = "YIrVxD2SaUyaEdMry2nAd2qG1E0V38QIV6t6rpguFwk=";
          };
        in
        {
          inherit (import overlay self super) rust-bin;
        }
      )
    ];

    opts = {
      system = {
        virtualization.enable = false;
        filesystem.type = "none";
        adminAllowNoPassword = true;
        login.auto = {
          enable = true;
          user = "timon";
        };
        desktops.guest.enable = true;
      };
      users = {
        timon = {
          admin = true;
          home = {
            name = "Timon Schelling";
            email = "me@timon.zip";
            desktops.guest.default.enable = true;
            apps = {
              terminal = {
                rio.enable = true;
              };
              editor = {
                vscode.enable = true;
                lapce.enable = true;
              };
              browser = {
                firefox.enable = true;
                chromium.enable = true;
                tor-browser.enable = true;
              };
              filemanager = {
                nautilus.enable = true;
              };
              utils = {
                btop.enable = true;
              };
            };
          };
        };
      };
    };
  };
}
