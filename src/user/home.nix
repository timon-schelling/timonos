{ lib, ... }: {
  options = {
    opts = {
      username = lib.mkOption {
        type = lib.types.str;
      };
      user = {
        name = lib.mkOption {
          type = lib.types.str;
        };
        email = lib.mkOption {
          type = lib.types.str;
        };
      };
    };
  };
}
