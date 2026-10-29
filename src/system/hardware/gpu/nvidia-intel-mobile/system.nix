{ lib, pkgs, config, ... }:

let
  cfg = config.opts.system.hardware.gpu.nvidia-intel-mobile;
in
{
  options = {
    opts.system.hardware.gpu.nvidia-intel-mobile = {
      enable = lib.mkEnableOption "Enable NVIDIA INTEL mobile GPU";
      mode = lib.mkOption {
        type = lib.types.enum [ "hybrid" "integrated" ];
        default = "integrated";
      };
      nvidiaBusId = lib.mkOption {
        type = lib.types.str;
      };
      intelBusId = lib.mkOption {
        type = lib.types.str;
      };
    };
  };
  config = lib.mkIf cfg.enable (lib.mkMerge [
    {
      hardware.graphics = {
        enable = true;
        extraPackages = with pkgs; [
          mesa
          intel-media-driver
          intel-vaapi-driver
        ];
      };
    }
    (lib.mkIf (cfg.mode == "integrated") {
      boot.extraModprobeConfig = ''
        blacklist nouveau
        options nouveau modeset=0
      '';
      services.udev.extraRules = ''
        ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x0c0330", ATTR{power/control}="auto", ATTR{remove}="1"
        ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x0c8000", ATTR{power/control}="auto", ATTR{remove}="1"
        ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x040300", ATTR{power/control}="auto", ATTR{remove}="1"
        ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x03[0-9]*", ATTR{power/control}="auto", ATTR{remove}="1"
      '';
      boot.blacklistedKernelModules = [ "nouveau" "nvidia" "nvidia_drm" "nvidia_modeset" ];
    })
    (lib.mkIf (cfg.mode == "hybrid") {
      services.xserver.videoDrivers = [ "nvidia" ];
      boot.kernelParams = [ "nvidia.NVreg_PreserveVideoMemoryAllocations=1" "nvidia_drm.fbdev=1" ];
      hardware = {
        nvidia = {
          package = config.boot.kernelPackages.nvidiaPackages.beta;
          open = true;
          modesetting.enable = true;
          powerManagement = {
            enable = true;
            finegrained = true;
          };
          prime = {
            offload = {
              enable = true;
              enableOffloadCmd = lib.mkForce true;
            };
            nvidiaBusId = cfg.nvidiaBusId;
            intelBusId = cfg.intelBusId;
          };
          nvidiaSettings = false;
        };
      };
      environment.variables = {
        "LIBVA_DRIVER_NAME" = "nvidia";
        "GBM_BACKEND" = "nvidia-drm";
        "__GLX_VENDOR_LIBRARY_NAME" = "nvidia";
      };
    })
  ]);
}
