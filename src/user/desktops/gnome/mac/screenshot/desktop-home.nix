{ pkgs, ... }:

{
  home.packages = [
    pkgs.gnome-screenshot
  ];
  dconf.settings = {
    "org/gnome/gnome-screenshot"= {
      auto-save-directory = "~/tmp";
      last-save-directory = "~/tmp";
    };
  };
}
