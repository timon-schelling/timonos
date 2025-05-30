{ lib, config, pkgs, ... }:

let
  cfg = config.opts.system.desktops.gnome;
in
{
  options.opts.system.desktops.gnome.enable = lib.mkEnableOption "Gnome Desktop";
  config = lib.mkIf cfg.enable {
    services.xserver.desktopManager.gnome.enable = true;
    services.gnome.core-utilities.enable = false;
    environment.gnome.excludePackages = [ pkgs.gnome-tour pkgs.xdg-user-dirs ];
  };
}
