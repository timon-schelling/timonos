{ lib, config, ... }:

let
  cfg = config.opts.system.hardware.fingerprint;
in
{
  options = {
    opts.system.hardware.fingerprint.enable = lib.mkEnableOption "fingerprint";
  };
  config = lib.mkIf cfg.enable {
    platform.system.persist.folders = [ "/var/lib/fprint" ];

    services.fprintd.enable = true;
  };
}
