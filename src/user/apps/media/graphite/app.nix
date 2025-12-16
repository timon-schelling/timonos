{ pkgs, config, lib, ... }:

{
  platform.user.persist.folders = [
    ".local/share/graphite"
  ];

  home.packages = [
    pkgs.zenity
    pkgs.graphite
  ];
}
