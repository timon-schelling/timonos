{ lib, config, pkgs, ... }:

{
  home.activation.addGtkSettingSchemas = ''
    export XDG_DATA_DIRS=''${XDG_DATA_DIRS:+:}${pkgs.gtk3}/share/gsettings-schemas/${pkgs.gtk3}
  '';
  gtk = {
    enable = true;
    theme = {
      package = pkgs.adw-gtk3;
      name = "adw-gtk3-dark";
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
    gtk4.theme = null;
  };
  dconf.settings = {
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
    };
    "org/gnome/desktop/wm/preferences" = {
      button-layout = "close,minimize,maximize:";
    };
  };
}
