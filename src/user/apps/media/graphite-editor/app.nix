{ pkgs, config, lib, ... }:

{
  platform.user.persist.folders = [
    ".local/share/graphite-desktop"
  ];

  home.packages = [
    pkgs.graphite-editor
  ];
}
