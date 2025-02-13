{ lib, config, ... }:

{
  options.opts.system.adminAllowNoPassword = lib.mkEnableOption "Allow admin users to sudo without a password";

  config = {
    security.sudo = {
      configFile = lib.mkForce ''
        root ALL=(ALL:ALL) SETENV: ALL
        %admin ALL=(ALL:ALL) SETENV${if config.opts.system.adminAllowNoPassword then ", NOPASSWD" else ""}: ALL

        Defaults lecture = never
      '';
    };
  };
}
