{ lib, pkgs, config, ... }:

{
  imports = [
    ../vm-base
    ../vm-base-workspace
  ];

  config = {
    vm.config = {
      cpu = {
        cores = 32;
      };
      memory = {
        size = 32000;
      };
    };

    environment.systemPackages = [
      pkgs.inkscape
    ];
  };
}
