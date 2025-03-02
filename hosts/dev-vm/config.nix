{ lib, pkgs, config, ... }:

{
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

    containConfig = lib.mkOption
    (
      let
        json = pkgs.formats.json {};
        conf = {
          initrd_path = config.vm.build.initrd;
          kernel_path = "${config.vm.build.kernel.dev}/vmlinux";
          cmdline = "console=hvc0 loglevel=4 reboot=t panic=-1 root=fstab init=${config.system.build.toplevel}/init regInfo=${pkgs.closureInfo {rootPaths = [ config.system.build.toplevel ];}}/registration";
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
                source = ".";
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
          console = {
            mode = "off";
          };
        };
      in
      {
        type = lib.types.path;
        default = json.generate "contain-dev-vm-config.json" conf;
      }
    );
  };

  config = {
    boot.postBootCommands = ''
      if [[ "$(cat /proc/cmdline)" =~ regInfo=([^ ]*) ]]; then
        ${config.nix.package.out}/bin/nix-store --load-db < ''${BASH_REMATCH[1]}
      fi
    '';
    systemd.sockets.nix-daemon.enable = lib.mkDefault true;
    systemd.services.nix-daemon.enable = lib.mkDefault true;

    systemd.services.mount-pstore.enable = false;
    systemd.services.logrotate-checkconf.enable = false;
    systemd.network.wait-online.enable = lib.mkDefault false;
    networking.firewall.enable = false;
    documentation.enable = lib.mkDefault false;

    fileSystems = {
      "/" = {
        device = "rootfs";
        fsType = "tmpfs";
        mountPoint = "/";
        neededForBoot = true;
        options = [
          "x-initrd.mount"
          "size=50%,mode=0755"
        ];
      };
      "/home/timon/workspace" = {
        device = "workspace-rw";
        fsType = "virtiofs";
        mountPoint = "/home/timon/workspace";
        options = [
          "defaults"
          "x-systemd.requires=systemd-modules-load.service"
        ];
      };
      "/nix/.ro-store" = {
        device = lib.mkForce "nix-store-ro";
        fsType = lib.mkForce "virtiofs";
        mountPoint = lib.mkForce "/nix/.ro-store";
        neededForBoot = lib.mkForce true;
        options = lib.mkForce [
          "x-initrd.mount"
          "defaults"
          "x-systemd.requires=systemd-modules-load.service"
        ];
      };
      "/nix/store" = {
        depends = [
          "/nix/.ro-store"
          "/nix/.rw-store"
        ];
        device = lib.mkForce "overlay";
        fsType = lib.mkForce "overlay";
        mountPoint = lib.mkForce "/nix/store";
        neededForBoot = lib.mkForce true;
        options = lib.mkForce [
          "x-initrd.mount"
          "x-systemd.requires-mounts-for=/sysroot/nix/.ro-store"
          "x-systemd.requires-mounts-for=/sysroot/nix/.rw-store"
          "lowerdir=/nix/.ro-store"
          "upperdir=/nix/.rw-store/store"
          "workdir=/nix/.rw-store/work"
        ];
      };
    };

    boot = {
      initrd.kernelModules = [
        "virtio_pci"
        "virtiofs"
        "overlay"
      ];
      kernelModules = [
        "drm"
        "virtio_gpu"
      ];
      blacklistedKernelModules = [
        "rfkill"
        "intel_pstate"
      ];
      kernelPatches = lib.singleton {
        name = "disable-drm-fbdev-emulation";
        patch = null;
        extraConfig = ''
          DRM_FBDEV_EMULATION n
        '';
      };
    };

    # boot.initrd.systemd patchups copied from <nixpkgs/nixos/modules/virtualisation/qemu-vm.nix>
    boot.initrd.systemd =
    let
      writableStoreOverlay = "/nix/.rw-store";
      roStore = "/nix/.ro-store";
    in
    {
      emergencyAccess = true;
      mounts = [ {
        where = "/sysroot/nix/store";
        what = "overlay";
        type = "overlay";
        options = builtins.concatStringsSep "," [
          "lowerdir=/sysroot${roStore}"
          "upperdir=/sysroot${writableStoreOverlay}/store"
          "workdir=/sysroot${writableStoreOverlay}/work"
        ];
        wantedBy = [ "initrd-fs.target" ];
        before = [ "initrd-fs.target" ];
        requires = [ "rw-store.service" ];
        after = [ "rw-store.service" ];
        unitConfig.RequiresMountsFor = "/sysroot/${roStore}";
      } ];
      services.rw-store = {
        unitConfig = {
          DefaultDependencies = false;
          RequiresMountsFor = "/sysroot${writableStoreOverlay}";
        };
        serviceConfig = {
          Type = "oneshot";
          ExecStart = "/bin/mkdir -p -m 0755 /sysroot${writableStoreOverlay}/store /sysroot${writableStoreOverlay}/work /sysroot/nix/store";
        };
      };
    };

    # Fix for hanging shutdown
    systemd.mounts = lib.mkIf config.boot.initrd.systemd.enable [ {
      what = "store";
      where = "/nix/store";
      overrideStrategy = "asDropin";
      unitConfig.DefaultDependencies = false;
    } ];

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
      (pkgs.nu.writeScriptBin "run-wayland-proxy" ''
        def --wrapped main [...args] {
          ${pkgs.wayland-proxy-virtwl}/bin/wayland-proxy-virtwl ---virtio-gpu -- ...$args
        }
      '')
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
      (final: prev: {
        stratovirt = prev.stratovirt.override { gtk3 = null; };
      })

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
        virtualization.contain.enable = true;
        virtualization.contain.guest.enable = true;
        virtualization.contain.host.enable = true;
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
