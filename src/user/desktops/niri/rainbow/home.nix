{ lib, config, pkgs, inputs, ... }@args:

let
  cfg = config.opts.user.desktops.niri.rainbow;
  enable = cfg.enable && config.opts.system.desktops.niri.enable;
in
{
  options.opts.user.desktops.niri.rainbow.enable =
    lib.mkEnableOption "Niri Desktop Configuration Rainbow";
  config = lib.mkMerge (
    builtins.map
    (module: lib.mkIf enable (builtins.import module args))
    (lib.imports.type "desktop-home" ./.)
  );
}
