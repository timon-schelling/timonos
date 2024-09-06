{ config, pkgs, ... }:

{
  platform.user.persist.folders = [

  ];

  home.packages = [
    pkgs.buttercup-desktop
  ];
}
