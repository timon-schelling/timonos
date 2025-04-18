{ lib, ... }:

let
  persist = import ./persist-option.nix lib;
in
{
  options = {
    opts.user.persist = {
      data = lib.mkOption {
        type = persist;
        default = {};
      };
      state = lib.mkOption {
        type = persist;
        default = {};
      };
    };
    platform.user.persist = lib.mkOption {
      type = persist;
      default = {};
      internal = true;
    };
  };
}
