{ lib, pkgs, inputs, config, ... }:

let
  netdevName = "vm-0";
in
{

  imports = [
    inputs.microvm.nixosModules.microvm
  ];

  options.vm.run = lib.mkOption {
    type = lib.types.package;
    default = pkgs.writeScriptBin "run-vm" ''
      #!${pkgs.bash}/bin/bash

      sudo ip tuntap add name ${netdevName} mode tap user $USER vnet_hdr multi_queue
      sudo ip link set ${netdevName} up
      (${pkgs.virtiofsd}/bin/virtiofsd --socket-path=dev-vm-virtiofs-ro-store.sock --shared-dir=/nix/store --tag ro-store) &
      ${config.microvm.declaredRunner}/bin/microvm-run
    '';
  };

  config = {
    microvm = {
      graphics.enable = true;
      hypervisor = "cloud-hypervisor";
      writableStoreOverlay = "/nix/.rw-store";
      mem = 8048;
      vcpu = 8;
      volumes = [ {
        image = "nix-store-overlay.img";
        mountPoint = "/nix/.rw-store";
        size = 2048;
      } ];
      shares = [
        {
          proto = "virtiofs";
          tag = "ro-store";
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
            RestartSec = 2;
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
