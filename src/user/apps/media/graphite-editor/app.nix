{ pkgs, config, lib, ... }:

{
  platform.user.persist.folders = [
    ".local/share/graphite-editor"
  ];

  home.packages = [
    pkgs.graphite-editor
  ];
}
