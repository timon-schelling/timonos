{ lib, config, ... }:

{
  options.opts.system.filesystem = lib.mkOption {
    type = lib.types.submodule {
      options = {
        type = lib.mkOption {
          type = lib.types.enum [ "impermanent" "ephemeral" "none" ];
          default = "impermanent";
        };
        drive = lib.mkOption{
          type = lib.types.str;
          default = "";
        };
        swap = lib.mkOption {
          type = lib.types.submodule {
            options = {
              enable = lib.mkOption {
                type = lib.types.bool;
                default = true;
              };
              size = lib.mkOption {
                type = lib.types.str;
                default = "32G";
              };
            };
          };
          default = { };
        };
        internal = lib.mkOption {
          type = lib.types.submodule {
            options = {
              persist = lib.mkOption {
                type = lib.types.submodule {
                  options = {
                    enable = lib.mkOption {
                      type = lib.types.bool;
                      default = (
                        config.opts.system.filesystem.type == "impermanent" ||
                        config.opts.system.filesystem.type == "ephemeral"
                      );
                      description = "persistence configuration with impermanece";
                    };
                  };
                };
                default = {};
              };
              drives = lib.mkOption {
                type = lib.types.submodule {
                  options = {
                    enable = lib.mkOption {
                      type = lib.types.bool;
                      default = (
                        config.opts.system.filesystem.type == "impermanent"
                      );
                      description = "drive configuration with disko";
                    };
                  };
                };
                default = {};
              };
              reset = lib.mkOption {
                type = lib.types.submodule {
                  options = {
                    enable = lib.mkOption {
                      type = lib.types.bool;
                      default = (
                        config.opts.system.filesystem.type == "impermanent"
                      );
                      description = "reset root filesystem with initrd service";
                    };
                  };
                };
                default = {};
              };
            };
          };
          internal = true;
          default = {};
        };
      };
    };
    default = { };
  };
}
