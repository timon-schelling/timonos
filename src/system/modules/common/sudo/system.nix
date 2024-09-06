{ lib, ... }:

{
  security.sudo = {
    configFile = lib.mkForce ''
      root ALL=(ALL:ALL) SETENV: ALL
      %admin ALL=(ALL:ALL) SETENV: ALL

      Defaults lecture = never
    '';
  };
}
