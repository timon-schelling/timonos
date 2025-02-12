{ lib, pkgs, inputs, config, ... }:

let
  netdevName = "vm-0";
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
        command = pkgs.nu.writeScript "vm-main" ''
              (
              ${pkgs.cloud-hypervisor-graphics}/bin/cloud-hypervisor
              --cpus "boot=16"
              --watchdog
              --console "off"
              --serial "off"
              --kernel ${kernelPath}
              --initramfs ${intirdPath}
              --cmdline "reboot=t panic=-1 root=fstab loglevel=4 init=${config.system.build.toplevel}/init regInfo=${pkgs.closureInfo {rootPaths = [ config.system.build.toplevel ];}}/registration"
              --seccomp "true"
              --memory "mergeable=on,shared=on,size=16384M"
              --platform "oem_strings=[io.systemd.credential:vmm.notify_socket=vsock-stream:2:8888]"
              --vsock "cid=3,socket=notify.vsock"
              --gpu "socket=gpu.sock"
              --disk "direct=off,num_queues=16,path=nix-store-rw-overlay.img,readonly=off"
              --fs "socket=nix-store-ro.sock,tag=nix-store-ro"
              --api-socket "api.sock"
              --net "mac=00:00:00:00:00:01,num_queues=16,tap=vm-0"
              )
        '';
      in
      {
        type = lib.types.package;
        default = pkgs.writeScriptBin "vm-some" ''
          #!${pkgs.bash}/bin/bash

          sudo ip tuntap add name ${netdevName} mode tap user $USER vnet_hdr multi_queue
          sudo ip link set ${netdevName} up

          rm -f nix-store-ro.sock
          ${pkgs.virtiofsd}/bin/virtiofsd --socket-path=nix-store-ro.sock --tag=nix-store-ro --shared-dir=/nix/store &

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
          mkfs.ext4   'nix-store-rw-overlay.img'

          rm -f api.sock
          ${command}
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
      ];
      interfaces = [
        {
          type = "tap";
          id = netdevName;
          mac = "00:00:00:00:00:01";
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
              ${pkgs.nushell}/bin/nu --login
            '';
          in
          {
            ExecStart = "${pkgs.wayland-proxy-virtwl}/bin/wayland-proxy-virtwl --virtio-gpu --tag='[vm] - ' --wayland-display wayland-main-terminal -- ${pkgs.rio}/bin/rio -e ${runMainTerminalScript}";
            Restart = "always";
            RestartSec = 1;
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
    ];

    opts = {
      system = {
        virtualization.enable = false;
        filesystem.type = "none";
        profile = "users.timon";
        login.auto = {
          enable = true;
          user = "timon";
        };
      };
    };
  };
}
