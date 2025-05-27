{ config, lib, pkgs, ... }:

let
  cfg = config.opts.system.virtualization.contain;
  vmResourcePrefix = "vm-";
  vmBridgeName = "bridge-vm";
in
{
  options = {
    opts.system.virtualization.contain = {
      enable = lib.mkEnableOption "Enable contain virtualization";
      host.enable = lib.mkOption {
        type = lib.types.bool;
        default = (!cfg.guest.enable);
      };
      guest.enable = lib.mkEnableOption "Enable contain guest";
    };
  };

  config = lib.mkMerge [
    (lib.mkIf (cfg.enable && cfg.host.enable) {
      environment.systemPackages = [
        pkgs.contain
      ];
    })
    (lib.mkIf (cfg.enable && cfg.host.enable) (
      let
        addColonsToIPv6 =
          string:
          if ((lib.stringLength string) > 4) then
            ((lib.substring 0 4 string) + ":" + (addColonsToIPv6 (lib.substring 4 32 string)))
          else
            string;
        generateIPv6ULAPrefixNoColons =
          hostname: "fd" + (lib.substring 0 14 (builtins.hashString "sha256" hostname));
        generateIPv6ULAPrefix = hostname: addColonsToIPv6 (generateIPv6ULAPrefixNoColons hostname);
        ipv6Prefix = generateIPv6ULAPrefix ("vm." + config.opts.system.host);
      in
      {
        systemd.network = {
          netdevs."10-${vmBridgeName}".netdevConfig = {
            Kind = "bridge";
            Name = vmBridgeName;
          };
          networks."10-${vmBridgeName}" = {
            matchConfig.Name = vmBridgeName;
            networkConfig = {
              DHCPServer = true;
              IPv6SendRA = true;
            };
            addresses = [
              {
                Address = "10.142.0.1/16";
              }
              {
                Address = "${ipv6Prefix}::1/64";
              }
            ];
            ipv6Prefixes = [ {
              Prefix = "${ipv6Prefix}::/64";
            } ];
          };
          networks."11-${vmResourcePrefix}-all" = {
            matchConfig.Name = "${vmResourcePrefix}*";
            networkConfig.Bridge = vmBridgeName;
          };
        };
        networking = {
          firewall.allowedUDPPorts = [ 67 ];
          nat = {
            enable = true;
            enableIPv6 = true;
            externalInterface = "main";
            internalInterfaces = [ vmBridgeName ];
          };
        };
        systemd.services."containd" = {
          enable = true;
          description = "contain daemon";
          wantedBy = [ "multi-user.target" ];
          serviceConfig = {
            Type = "simple";
            ExecStart = "${pkgs.containd}/bin/containd";
            Restart = "always";
          };
        };
      }
    ))
  ];
}
