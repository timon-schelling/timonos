{ lib, ... }:

{
  options = {
    opts.system = {
      host = lib.mkOption {
        type = lib.types.str;
      };
      platform = lib.mkOption {
        type = lib.types.str;
        default = "x86_64-linux";
      };
      stateVersion = lib.mkOption {
        type = lib.types.str;
        default = "25.05";
      };
    };
  };
}
