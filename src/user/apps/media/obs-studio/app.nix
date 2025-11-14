{ pkgs, config, lib, ... }:

{
  platform.user.persist.folders = [
    ".config/obs-studio"
  ];

  home.packages = [
    pkgs.obs-studio
  ];
}
