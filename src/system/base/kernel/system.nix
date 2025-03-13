{ pkgs, ... }:

let
  kernelPkgs = pkgs.linuxPackages_6_12;
in
{
  boot = {
    kernelPackages = kernelPkgs;
    kernelModules = [ "i2c-dev" "ddcci" "ddcci_backlight" ];
    extraModulePackages = [ kernelPkgs.ddcci-driver ];
  };
}
