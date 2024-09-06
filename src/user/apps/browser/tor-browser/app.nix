{ config, lib, pkgs, ... }:

{
  home.packages = [
    pkgs.tor-browser
  ];
}
