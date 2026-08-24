{ lib, config, pkgs, ... }:

let
  cfg = config.opts.system.desktops.hyprland;
in
{
  options.opts.system.desktops.hyprland.enable = lib.mkEnableOption "Hyprland Desktop";
  config = lib.mkIf cfg.enable {
    programs.hyprland = {
      enable = true;
    };

    programs.dconf.enable = true;
    xdg.portal = {
      enable = true;
      extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    };

    services.gvfs.enable = config.opts.system.hardware.automount.enable;

    services.upower.enable = true;
    services.power-profiles-daemon.enable = true;
  };
}
