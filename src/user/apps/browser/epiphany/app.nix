{ pkgs, ... }:

{
  platform.user.persist.folders = [
    ".local/share/epiphany"
  ];
  home.packages = [
    pkgs.epiphany
  ];
}
