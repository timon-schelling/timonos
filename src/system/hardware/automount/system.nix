{ lib, config, ... }:

let
  cfg = config.opts.system.hardware.automount;
in
{
  options = {
    opts.system.hardware.automount.enable = lib.mkEnableOption "removable drive automounting";
  };
  config = lib.mkIf cfg.enable {
    services.udisks2.enable = true;
    services.devmon.enable = true;
  };
}
