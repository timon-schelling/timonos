{ config, pkgs, ... }:

let
  themePkg = pkgs.whitesur-gtk-theme.override {
    defaultActivities = true;
  };
  themeName = "WhiteSur-Dark-solid";
in
{
  home.sessionVariables = {
    GTK_THEME = themeName;
  };
  systemd.user.sessionVariables = {
    GTK_THEME = themeName;
  };
  gtk = {
    enable = true;
    theme = {
      package = themePkg;
      name = themeName;
    };

    iconTheme = {
      package = pkgs.whitesur-icon-theme;
      name = "WhiteSur-dark";
    };

    font = {
      name = "Sans";
      size = 11;
    };
    gtk3.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
    };
    gtk4.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
    };
  };
  dconf.settings = {
    "org/gnome/desktop/wm/preferences" = {
      button-layout = "close,minimize,maximize:";
    };
  };
}
