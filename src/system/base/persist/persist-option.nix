lib: lib.mkOption {
  type = lib.types.submodule {
    options = {
      folders = lib.mkOption {
        type = lib.types.listOf lib.types.anything;
        default = [ ];
      };
      files = lib.mkOption {
        type = lib.types.listOf lib.types.anything;
        default = [ ];
      };
    };
  };
  default = { };
}
