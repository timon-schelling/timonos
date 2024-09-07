{ config, pkgs, ... }:

{
  home.sessionVariables = {
    GTK_THEME = config.gtk.theme.name;
  };
  systemd.user.sessionVariables = {
    GTK_THEME = config.gtk.theme.name;
  };
  gtk = {
    enable = true;
    theme = {
      package = pkgs.whitesur-gtk-theme;
      name = "WhiteSur-Dark-solid";
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
}
