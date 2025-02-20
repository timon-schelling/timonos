{ lib, pkgs, inputs, config, ... }:

# let workspace_dir = $"(pwd)/workspace"
# cd vm
# try { rm -r ./* }
# nix run $"($env.HOME)/tmp/timonos#nixosConfigurations.dev-vm.config.vm.run" $workspace_dir

let
  console = "none"; # "none", "tty", "serial"
in
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

    run = lib.mkOption (

      let
        kernel = config.vm.build.kernel;
        kernelPath = {
          x86_64-linux = "${kernel.dev}/vmlinux";
          aarch64-linux = "${kernel.out}/${pkgs.stdenv.hostPlatform.linux-kernel.target}";
        }.${pkgs.stdenv.system};
        intirdPath = config.vm.build.initrd;
        kernelConsole = if console == "none" then "" else (
          if console == "tty" then "console=ttyS0 "
          else "earlyprintk=ttyS0 console=ttyS0 "
        );
        command = pkgs.nu.writeScript "vm-main" ''
              (
              ${pkgs.cloud-hypervisor-graphics}/bin/cloud-hypervisor
              --cpus "boot=16"
              --watchdog
              ${if console == "tty" then "--console \"tty\"" else "--console \"off\""}
              ${if console == "serial" then "--serial \"tty\"" else "--serial \"off\""}
              --kernel ${kernelPath}
              --initramfs ${intirdPath}
              --cmdline "${kernelConsole}reboot=t panic=-1 root=fstab loglevel=4 init=${config.system.build.toplevel}/init regInfo=${pkgs.closureInfo {rootPaths = [ config.system.build.toplevel ];}}/registration"
              --seccomp "true"
              --memory "mergeable=on,shared=on,size=16384M"
              --platform "oem_strings=[io.systemd.credential:vmm.notify_socket=vsock-stream:2:8888]"
              --vsock "cid=3,socket=notify.vsock"
              --gpu "socket=gpu.sock"
              --disk "direct=off,num_queues=16,path=nix-store-rw-overlay.img,readonly=off"
              --fs
              "socket=nix-store-ro.sock,tag=nix-store-ro"
              "socket=workspace-rw.sock,tag=workspace-rw"
              --api-socket "api.sock"
              --net $"num_queues=16,tap=(open ./tap)"
              )
        '';
      in
      {
        type = lib.types.package;
        default = pkgs.writeScriptBin "vm" ''
          #!${pkgs.bash}/bin/bash

          ${pkgs.nu.writeScript "vm-request-tap-device" ''
            ${pkgs.containd}/bin/client create $env.USER | from json | get name | save -f ./tap
          ''}

          rm -f nix-store-ro.sock
          ${pkgs.virtiofsd}/bin/virtiofsd --socket-path=nix-store-ro.sock --tag=nix-store-ro --shared-dir=/nix/store &

          rm -f workspace-rw.sock
          ${pkgs.virtiofsd}/bin/virtiofsd --socket-path=workspace-rw.sock --tag=workspace-rw --shared-dir=$1 &

          rm -f gpu.sock
          ${pkgs.crosvm}/bin/crosvm device gpu --socket gpu.sock --wayland-sock $XDG_RUNTIME_DIR/$WAYLAND_DISPLAY --params '{"context-types":"virgl:virgl2:cross-domain","displays":[{"hidden":true}],"egl":true,"vulkan":true}' &
          while ! [ -S gpu.sock ]; do
            sleep .1
          done

          PATH=$PATH:${with pkgs.buildPackages; lib.makeBinPath [ coreutils util-linux e2fsprogs xfsprogs dosfstools btrfs-progs ]}
          rm -f nix-store-rw-overlay.img
          touch 'nix-store-rw-overlay.img'
          chattr +C 'nix-store-rw-overlay.img' || true
          truncate -s 2048M 'nix-store-rw-overlay.img'
          mkfs.ext4 'nix-store-rw-overlay.img'

          rm -f api.sock
          ${command}

          ${pkgs.containd}/bin/client delete $(cat ./tap)
          rm ./tap
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
      volumes = [ {
        image = "nix-store-rw-overlay.img";
        mountPoint = "/nix/.rw-store";
        size = 2048;
      } ];
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
