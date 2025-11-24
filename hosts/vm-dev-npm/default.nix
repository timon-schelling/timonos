{ lib, pkgs, config, ... }:

{
  imports = [
    ../vm-base
    ../vm-base-workspace
    ../vm-base-vcs
  ];

  config = {
    environment.systemPackages = with pkgs; [
      nodejs
      nodePackages.npm
    ];
  };
}
