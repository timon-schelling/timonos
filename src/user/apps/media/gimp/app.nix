{ pkgs, config, lib, ... }:

{
  platform.user.persist.folders = [
    ".config/GIMP"
    ".cache/gimp"
  ];

  home.packages = [
    pkgs.gimp3
  ];
}
