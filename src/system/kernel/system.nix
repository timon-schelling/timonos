{ pkgs, ... }:

let
  kernelPkgs = pkgs.linuxPackages_latest;
in
{
  boot = {
    kernelPackages = kernelPkgs;
    kernelModules = [ "i2c-dev" "ddcci" "ddcci_backlight" ];
    extraModulePackages = [
      (kernelPkgs.ddcci-driver.overrideAttrs (old: {
        src = pkgs.fetchFromGitLab {
          owner = "ddcci-driver-linux";
          repo = "ddcci-driver-linux";
          rev = "7853cbfc28bc62e87db79f612568b25315397dd0";
          hash = "sha256-QImfvYzMqyrRGyrS6I7ERYmteaTijd8ZRnC6+bA9OyM=";
        };
        patches = [];
      }))
    ];
  };
  # security.lockKernelModules = true;
}
