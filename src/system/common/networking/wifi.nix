{ config, lib, pkgs, ... }:

let
  cfg = config.opts.system.network.wifi;
in
{
  options = {
    opts = {
      system.network.wifi.enable = lib.mkEnableOption "Enable wifi";
      users = lib.mkOption {
        type = lib.types.attrsOf (lib.types.submodule {
          options = {
            allowWifiSettings = lib.mkOption {
              type = lib.types.bool;
              default = true;
            };
          };
        });
      };
    };
  };

  config = lib.mkIf cfg.enable {
    platform.system.persist.folders = [ "/var/lib/iwd" ];
    networking = {
      wireless.enable = false;
      wireless.iwd = {
        enable = true;
        settings = {
          General = {
            EnableNetworkConfiguration = false;
          };
          Network = {
            EnableIPv6 = true;
            RoutePriorityOffset = 300;
            NameResolvingService = "systemd";
          };
          Settings = {
            AutoConnect = true;
            Hidden = true;
            AlwaysRandomizeAddress = false;
          };
        };
      };
    };

    users = {
      users = lib.mkMerge (lib.mapAttrsToList
        (name: user: {
          ${name} = {
            extraGroups = (if user.allowWifiSettings then [ "wifi" ] else [ ]);
          };
        })
        config.opts.users
      );
    };

    users.groups."wifi" = {};
    services.dbus.packages = lib.mkAfter [
      (pkgs.writeTextDir "etc/dbus-1/system.d/iwd-dbus-allow-wifi-group.conf" ''
        <busconfig>
          <policy group="wifi">
            <allow send_destination="net.connman.iwd"/>
          </policy>
        </busconfig>
      '')
    ];
  };
}
