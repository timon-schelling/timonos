{ pkgs, ... }:

{
  home.packages = [
    pkgs.nautilus
    pkgs.file-roller
  ];

  dconf.settings = {
    "org/gnome/nautilus/preferences" = {
      show-hidden-files = true;
    };
  };
}
