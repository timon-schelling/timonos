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

    environment.sessionVariables = {
      WAYLAND_DISPLAY = "wayland-1";
      DISPLAY = ":0";
      QT_QPA_PLATFORM = "wayland"; # Qt Applications
      GDK_BACKEND = "wayland"; # GTK Applications
      XDG_SESSION_TYPE = "wayland"; # Electron Applications
      SDL_VIDEODRIVER = "wayland";
      CLUTTER_BACKEND = "wayland";
    };

    systemd.user.services.wayland-proxy = {
      enable = true;
      description = "Wayland Proxy";
      serviceConfig = with pkgs; {
        # Environment = "WAYLAND_DISPLAY=wayland-1";
        ExecStart = "${sommelier}/bin/sommelier --virtgpu-channel --display=$XDG_RUNTIME_DIR/wayland-1";
        Restart = "on-failure";
        RestartSec = 5;
      };
      wantedBy = [ "default.target" ];
    };

    environment.systemPackages = with pkgs; [
      sommelier
      neverball
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
