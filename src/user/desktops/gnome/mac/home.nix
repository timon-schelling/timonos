{ lib, config, pkgs, inputs, ... }@args:

let
  cfg = config.opts.user.desktops.gnome.mac;
  enable = cfg.enable && config.opts.system.desktops.gnome.enable;
in
{
  options.opts.user.desktops.gnome.mac.enable =
    lib.mkEnableOption "Gnome Desktop Configuration Mac";
  config = lib.mkMerge (
    builtins.map
    (module: lib.mkIf enable (builtins.import module args))
    (lib.imports.type "desktop-home" ./.)
  );
}
