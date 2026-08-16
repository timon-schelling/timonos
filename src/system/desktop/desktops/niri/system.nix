{ lib, config, pkgs, inputs, ... }@args:

let
  cfg = config.opts.system.desktops.niri;
in
{
  options.opts.system.desktops.niri.enable = lib.mkEnableOption "Niri Desktop";
  config = lib.mkIf cfg.enable {
    programs.niri = {
      enable = true;
    };

    # niri ships a portals.conf preferring gnome then gtk, gtk alone covers it
    xdg.portal = {
      enable = true;
      extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    };
  };
}
