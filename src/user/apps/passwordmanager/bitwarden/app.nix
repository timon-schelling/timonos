{ config, pkgs, ... }:

{
  platform.user.persist.folders = [
    ".config/Bitwarden"
  ];

  home.packages = [
    pkgs.bitwarden-desktop
  ];
}
