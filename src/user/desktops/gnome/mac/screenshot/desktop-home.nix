{ pkgs, ... }:

{
  home.packages = [
    pkgs.pkgs.gnome.gnome-screenshot
  ];
  dconf.settings = {
    "org/gnome/gnome-screenshot"= {
      auto-save-directory = "~/tmp";
      last-save-directory = "~/tmp";
    };
  };
}
