{ pkgs, config, lib, ... }:

{
  platform.user.persist.folders = [
    ".local/share/graphite-editor"
  ];

  home.packages = [
    pkgs.zenity
    pkgs.graphite-editor
  ];
}
