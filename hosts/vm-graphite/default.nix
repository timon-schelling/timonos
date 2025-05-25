{ lib, pkgs, config, ... }:

{
  imports = [
    ../vm-base
    ../vm-base-workspace
  ];

  config = {
    environment.systemPackages = [
      pkgs.graphite-desktop
    ];
  };
}
