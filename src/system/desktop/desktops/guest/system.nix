{ lib, config, ... }:

let
  cfg = config.opts.system.desktops.guest;
in
{
  options.opts.system.desktops.guest.enable = lib.mkEnableOption "Guest Desktop";
  config = lib.mkIf cfg.enable {
    programs.dconf.enable = true;
  };
}
