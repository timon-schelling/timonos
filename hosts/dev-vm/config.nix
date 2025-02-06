{ lib, pkgs, inputs, config, ... }:

{

  imports = [
    inputs.microvm.nixosModules.microvm
  ];

  options.contain.run = lib.mkOption {
    type = lib.types.package;
    default = pkgs.nu.writeScriptBin "contain-run" ''
      ${pkgs.sommelier}/bin/crosvm --help
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
        size = 256;
      } ];
      shares = [
        {
          proto = "virtiofs";
          tag = "ro-store";
          source = "/nix/store";
          mountPoint = "/nix/.ro-store";
        }
      ];
    };

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
      QT_QPA_PLATFORM = "wayland"; # Qt Applications
      GDK_BACKEND = "wayland"; # GTK Applications
      XDG_SESSION_TYPE = "wayland"; # Electron Applications
      SDL_VIDEODRIVER = "wayland";
      CLUTTER_BACKEND = "wayland";
    };

    systemd.user.services = {
      wayland-proxy = {
        enable = true;
        description = "wayland proxy";
        serviceConfig = {
          ExecStart = "${pkgs.wayland-proxy-virtwl}/bin/wayland-proxy-virtwl --virtio-gpu --x-display=0 --xwayland-binary=${pkgs.xwayland}/bin/Xwayland";
          Restart = "on-failure";
          RestartSec = 5;
        };
        wantedBy = [ "default.target" ];
      };
    };

    environment.systemPackages =
    let
      runSommelierScriptText = ''
        def --wrapped main [...args] {
          ${pkgs.sommelier} --virtgpu-channel ...$args
        }
      '';
    in
    [
      (pkgs.nu.writeScriptBin "run-sommelier" runSommelierScriptText)
      (pkgs.nu.writeScriptBin "run-wl" runSommelierScriptText)
    ];

    opts = {
      system = {
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
