{ pkgs, ... }:

let
  kernelPkgs = pkgs.linuxPackages;
in
{
  boot = {
    kernelPackages = kernelPkgs;
    kernelModules = [ "i2c-dev" "ddcci" "ddcci_backlight" ];
    extraModulePackages = [ kernelPkgs.ddcci-driver ];
  };
}
