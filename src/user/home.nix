{ lib, ... }: {
  options = {
    opts = {
      username = lib.mkOption {
        type = lib.types.str;
      };
      user = {
        name = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
          default = null;
        };
        email = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
          default = null;
        };
      };
    };
  };
}
