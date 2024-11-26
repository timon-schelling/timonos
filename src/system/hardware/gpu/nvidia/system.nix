{ lib, config, ... }:

let
  cfg = config.opts.system.hardware.gpu.nvidia;
  driverPkg = config.boot.kernelPackages.nvidiaPackages.beta;
in
{
  options = {
    opts.system.hardware.gpu.nvidia.enable = lib.mkEnableOption "Enable Nvidia GPU";
  };
  config = lib.mkIf cfg.enable {
    services.xserver.videoDrivers = [ "nvidia" ];
    boot.kernelParams = [
      "nvidia.NVreg_PreserveVideoMemoryAllocations=1"
      "nvidia_drm.fbdev=1"
    ];
    hardware.nvidia = {
      modesetting.enable = true;
      powerManagement = {
        enable = true;
        finegrained = false;
      };
      open = true;
      nvidiaSettings = false;
      package = driverPkg;
    };
    hardware.graphics = {
      enable = true;
      package = driverPkg;
      enable32Bit = true;
    };
    nixpkgs.config = {
      allowUnfree = true;
      nvidia.acceptLicense = true;
    };
  };
}
