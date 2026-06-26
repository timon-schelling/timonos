{ pkgs, config, lib, ... }:

{
  platform.user.persist.folders = [
    ".local/share/kdenlive"
    ".cache/kdenlive"
  ];

  home.packages = [
    pkgs.pkgs.kdePackages.kdenlive
  ];
}
