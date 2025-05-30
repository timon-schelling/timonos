{ config, lib, inputs, ... }:

let
  cfg = config.opts.system.virtualization.contain;
in
{
imports = [
  inputs.contain.nixosModules.host
];

  options = {
    opts.system.virtualization.contain = {
      enable = lib.mkEnableOption "contain virtualization";
    };
  };

  config = lib.mkMerge [
    (lib.mkIf (cfg.enable) {
      contain.host = {
        enable = true;
        network.enable = true;
      };

      systemd.network = {
        netdevs."10-contain-bridge".netdevConfig = {
          Kind = "bridge";
          Name = "contain-bridge";
        };
        networks."10-contain-bridge" = (
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
            matchConfig.Name = "contain-bridge";
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
          }
        );
      };
      networking = {
        firewall.allowedUDPPorts = [ 67 ];
        nat = {
          enable = true;
          enableIPv6 = true;
          externalInterface = "main";
          internalInterfaces = [ "contain-bridge" ];
        };
      };
    })
  ];
}
