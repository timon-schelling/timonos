{ lib, ... }:

let
  persist = import ./persist-option.nix lib;
in
{
  options = {
    opts.system.persist = persist;
    platform.system.persist = persist;
  };
}
