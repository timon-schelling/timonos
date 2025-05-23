{ lib, pkgs, inputs, config, ... }:

{
  imports = [
    inputs.home-manager.nixosModules.default
  ];

  options = {
    opts.users = lib.mkOption {
      type = lib.types.attrsOf (lib.types.submodule {
        options = {
          passwordHash = lib.mkOption {
            type = lib.types.str;
            default = "";
          };
          admin = lib.mkOption {
            type = lib.types.bool;
            default = false;
          };
          groups = lib.mkOption {
            type = lib.types.listOf lib.types.str;
            default = [ ];
          };
          home = lib.mkOption {
            type = lib.types.anything;
            default = { };
          };
        };
      });
      default = { };
    };
  };

  config = {
    users = {
      groups.admin = {};
      users = lib.mkMerge (lib.mapAttrsToList
        (name: user: {
          ${name} = lib.mkMerge [
            {
              isNormalUser = true;
              home = "/home/${name}";
              extraGroups = user.groups ++ (if user.admin then [ "admin" ] else [ ]);
              shell = pkgs.nushell;
            }
            (lib.mkIf (user.passwordHash != "") {
              hashedPassword = user.passwordHash;
            })
          ];
        })
        config.opts.users
      );
    };
    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      extraSpecialArgs = {
        inherit inputs;
        lib = (lib.extend (_: _: inputs.home-manager.lib));
      };
      users = lib.mkMerge (lib.mapAttrsToList
        (username: user:
          let
            opts = {
              system = config.opts.system;
              inherit username;
              user = user.home;
            };
            platform = {
              system = config.platform.system;
            };
            modules = (lib.imports.type "home" ./.) ++ [ ../profiles/home/home.nix ];
          in
          {
            ${username} = { lib, ...}: {
              imports = modules;

              options = {
                opts = {
                  system = lib.mkOption {
                    type = lib.types.anything;
                  };
                };
                platform = {
                  system = lib.mkOption {
                    type = lib.types.anything;
                  };
                };
              };

              config = {
                inherit opts platform;
              };
            };
          }
        )
        config.opts.users
      );
    };
  };
}
