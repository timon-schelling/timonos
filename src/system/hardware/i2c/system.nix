{ lib, config, ... }:

let
  cfg = config.opts.system.hardware.i2c;
in
{
  options.opts.system.hardware.i2c.enable = lib.mkEnableOption "I2C device access";
  config = lib.mkIf cfg.enable {
    hardware.i2c.enable = true;

    users.users = lib.mkMerge (lib.mapAttrsToList
      (name: user: {
        ${name}.extraGroups = [ "i2c" ];
      })
      config.opts.users
    );
  };
}
