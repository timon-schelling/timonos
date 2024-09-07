{ lib, config, pkgs, inputs, ... }@args:

let
  cfg = config.opts.user.desktops.hyprland.rainbow;
  enable = cfg.enable && config.opts.system.desktops.hyprland.enable;
in
{
  options.opts.user.desktops.hyprland.rainbow.enable =
    lib.mkEnableOption "Hyprland Desktop Configuration Rainbow";
  config = lib.mkMerge (
    builtins.map
    (module: lib.mkIf enable (builtins.import module args))
    (lib.imports.type "desktop-home" ./.)
  );
}
