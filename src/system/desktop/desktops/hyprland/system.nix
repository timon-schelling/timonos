{ lib, config, pkgs, inputs, ... }@args:

let
  cfg = config.opts.system.desktops.hyprland;
in
{
  options.opts.system.desktops.hyprland.enable = lib.mkEnableOption "Hyprland Desktop";
  config = lib.mkIf cfg.enable {
    programs.hyprland = {
      enable = true;
    };

    xdg.portal = {
      enable = true;
      wlr.enable = true;
    };
  };
}
