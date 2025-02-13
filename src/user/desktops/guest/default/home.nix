{ lib, config, pkgs, inputs, ... }@args:

let
  cfg = config.opts.user.desktops.guest.default;
  enable = cfg.enable && config.opts.system.desktops.guest.enable;
in
{
  options.opts.user.desktops.guest.default.enable =
    lib.mkEnableOption "Guest Desktop Configuration Default";
  config = lib.mkMerge (
    builtins.map
    (module: lib.mkIf enable (builtins.import module args))
    (lib.imports.type "desktop-home" ./.)
  );
}
