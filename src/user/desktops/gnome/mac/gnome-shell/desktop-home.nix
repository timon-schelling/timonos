{  pkgs, lib, ... }:

let
  themePkg = pkgs.whitesur-gtk-theme.override {
    defaultActivities = true;
  };
  themeName = "WhiteSur-Dark-solid";
in
{
  platform.user.persist.folders = [
    ".config/dconf"
  ];
  programs.gnome-shell = {
    enable = true;
    theme = {
      package = themePkg;
      name = themeName;
    };
  };
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
  dconf = {
    enable = true;
    settings = {
      "org/gnome/shell" = {
        disable-user-extensions = false;
        # `gnome-extensions list` for a list
        enabled-extensions = [
          "Vitals@CoreCoding.com"
          "dash-to-dock@micxgx.gmail.com"
          # "dash-to-panel@jderose9.github.com"
          "rounded-window-corners@fxgn"
        ];
      };
      "org/gnome/desktop/interface" = {
        color-scheme = "prefer-dark";
        enable-hot-corners = false;
      };
      "org/gnome/shell/extensions/vitals" = {
        show-storage = true;
        show-voltage = true;
        show-memory = true;
        show-fan = true;
        show-temperature = true;
        show-processor = true;
        show-network = true;
      };
      "org/gnome/desktop/wm/preferences" = {
        button-layout = "close,minimize,maximize:";
      };
      "org/gnome/mutter" = {
        dynamic-workspaces = true;
        edge-tiling = true;
      };
      "org/gtk/settings/file-chooser" = {
        show-hidden = true;
      };
      "org/gnome/desktop/background" = {
        picture-options = "zoom";
        picture-uri = "file:///run/current-system/sw/share/backgrounds/gnome/amber-l.jxl";
        picture-uri-dark = "file:///run/current-system/sw/share/backgrounds/gnome/amber-d.jxl";
      };
    };
  };

  home.packages = with pkgs; [
    gnomeExtensions.vitals
    gnomeExtensions.dash-to-panel
    gnomeExtensions.dash-to-dock
    gnomeExtensions.rounded-window-corners-reborn
  ];
}
