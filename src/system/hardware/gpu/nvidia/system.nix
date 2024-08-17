{ config, ... }:

let
  driverPkg = config.boot.kernelPackages.nvidiaPackages.beta;
in
{
  services.xserver.videoDrivers = [ "nvidia" ];
  boot.kernelParams = [ "nvidia.NVreg_PreserveVideoMemoryAllocations=1" "nvidia_drm.fbdev=1" ];
  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement = {
      enable = true;
      finegrained = false;
    };
    open = false;
    nvidiaSettings = false;
    package = driverPkg;
  };
  hardware.graphics = {
    enable = true;
    package = driverPkg;
  };
  nixpkgs.config = {
    allowUnfree = true;
    nvidia.acceptLicense = true;
  };

  imports = [
    ./monitor-ddcci-fix.nix
  ];
}
