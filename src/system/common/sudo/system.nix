{ lib, config, ... }:

{
  options.opts.system.sudo = {
    noPassword = lib.mkEnableOption "Allow admin users to sudo without a password";
    timeout = lib.mkOption {
      type = lib.types.int;
      default = 15;
    };
  };

  config = {
    security.sudo = {
      configFile = lib.mkForce ''
        root ALL=(ALL:ALL) SETENV: ALL
        %admin ALL=(ALL:ALL) SETENV${if config.opts.system.sudo.noPassword then ", NOPASSWD" else ""}: ALL

        Defaults timestamp_timeout=${toString config.opts.system.sudo.timeout}
        Defaults lecture = never
      '';
    };
  };
}
