{ lib, ... }:

let
  persist = import ./persist-option.nix lib;
in
{
  options = {
    opts.user.persist = {
      data = persist;
      state = persist;
    };
    platform.user.persist = persist;
  };
}
