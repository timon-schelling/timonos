{ lib, config, ... }:

let
  cfg = config.opts.system.hardware.bluetooth;
in
{
  options = {
    opts.system.hardware.bluetooth.enable = lib.mkEnableOption "Bluetooth";
  };
  config = lib.mkIf cfg.enable {

    platform.system.persist.folders = [ "/var/lib/bluetooth" ];

    hardware.bluetooth = {
      enable = true;
      powerOnBoot = true;
    };
    services.blueman.enable = true;
  };
}
