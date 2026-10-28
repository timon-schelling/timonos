{ lib, config, ... }:

let
  cfg = config.opts.system.hardware.logitech;
in
{
  options = {
    opts.system.hardware.logitech.enable = lib.mkEnableOption "logitech";
  };
  config = lib.mkIf cfg.enable {
    hardware.logitech.wireless.enable = true;
    programs.solaar.enable = true;
  };
}
