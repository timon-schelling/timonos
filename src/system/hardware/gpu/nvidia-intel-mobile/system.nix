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
          intel-media-driver
          intel-vaapi-driver
        ];
      };
    }
    (lib.mkIf (cfg.mode == "integrated") {
      hardware.nvidiaOptimus.disable = true;
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
            nvidiaBusId = cfg.nvidiaBusId; #"PCI:1:0:0";
            intelBusId = cfg.intelBusId; #"PCI:0:2:0";
          };
          nvidiaSettings = false;
        };
      };
    })
  ]);
}
