{ pkgs, config, lib, ... }:

{
  platform.user.persist.folders = [
    "src/user/apps/media/music-player"
  ];

  home.packages = [
    pkgs.graphite-desktop
  ];
}
