{ pkgs, ... }:

{
  home.packages = [
    pkgs.nautilus
    pkgs.file-roller
  ];
}
