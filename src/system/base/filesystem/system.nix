{ lib, config, ... }:

{
  options.opts.system.filesystem = lib.mkOption {
    type = lib.types.submodule {
      options = {
        type = lib.mkOption {
          type = lib.types.enum [ "impermanent" "none" ];
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
          default = {};
        };
      };
    };
    default = {};
  };

  config = lib.mkIf (config.opts.system.filesystem.type != "none") {
    assertions = [
      {
        assertion = !(config.opts.system.filesystem.drive == "");
        message = ''
          You must specify a drive for the root filesystem
          when using the "${config.opts.system.filesystem.type}" filesystem type
        '';
      }
    ];
  };
}
