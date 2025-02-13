{ pkgs, ... }:

{
  home.packages = [
    pkgs.nautilus
    pkgs.file-roller
  ];

  dconf = {
    enable = true;
    settings = {
      "org/gtk/settings/file-chooser" = {
        show-hidden = true;
      };
      "org/gtk/gtk4/settings/file-chooser" = {
        show-hidden = true;
      };
      "org/gnome/nautilus/preferences" = {
        show-hidden-files = true;
      };
    };
  };
}
