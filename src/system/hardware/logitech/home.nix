{ lib, config, ... }:

let
  cfg = config.opts.system.hardware.logitech;
in
{
  config = lib.mkIf cfg.enable {
    platform.user.persist.folders = [
      ".config/solaar"
    ];
  };
}
