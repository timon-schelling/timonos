{ lib, ... }:

let
  persist = import ./persist-option.nix lib;
in
{
  options = {
    opts.system.persist = lib.mkOption {
      type = persist;
      default = {};
    };
    platform.system.persist = lib.mkOption {
      type = persist;
      default = {};
      internal = true;
    };
  };
}
