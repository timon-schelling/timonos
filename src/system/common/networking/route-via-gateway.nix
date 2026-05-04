{ config, lib, pkgs, ... }:

{
  options.opts.system.network.routeViaGateway = lib.mkOption {
    type = lib.types.listOf lib.types.str;
    default = [];
    example = [ "10.0.0.0/8" "192.168.0.0/16" "fd00::/8" ];
  };

  config =
    let
      cfg = config.opts.system.network.routeViaGateway;
      isIPv6 = range: builtins.match ".*:.*" range != null;
      ipv4Ranges = builtins.filter (r: !(isIPv6 r)) cfg;
      ipv6Ranges = builtins.filter isIPv6 cfg;
    in
    lib.mkIf (cfg != []) {
      services.networkd-dispatcher = {
        enable = true;
        rules."route-via-gateway" = {
          onState = [ "routable" ];
          script = ''
            #!${pkgs.bash}/bin/bash
            if [ "$IFACE" != "main" ]; then exit 0; fi

            ${lib.optionalString (ipv4Ranges != []) ''
              GW4=$(${pkgs.iproute2}/bin/ip route show default dev main | ${pkgs.gawk}/bin/awk '{print $3; exit}')
              if [ -n "$GW4" ]; then
                ${
                  lib.concatMapStrings (range: ''
                    ${pkgs.iproute2}/bin/ip route replace "${range}" via "$GW4" metric 512
                  '') ipv4Ranges
                }
              fi
            ''}

            ${lib.optionalString (ipv6Ranges != []) ''
              GW6=$(${pkgs.iproute2}/bin/ip -6 route show default dev main | ${pkgs.gawk}/bin/awk '{print $3; exit}')
              if [ -n "$GW6" ]; then
                ${
                  lib.concatMapStrings (range: ''
                    ${pkgs.iproute2}/bin/ip -6 route replace "${range}" via "$GW6" metric 512
                  '') ipv6Ranges
                }
              fi
            ''}
          '';
        };
      };

      boot.kernel.sysctl = lib.mkMerge [
        (lib.mkIf (ipv4Ranges != []) {
          "net.ipv4.conf.all.accept_redirects" = 0;
          "net.ipv4.conf.main.accept_redirects" = 0;
        })
        (lib.mkIf (ipv6Ranges != []) {
          "net.ipv6.conf.all.accept_redirects" = 0;
          "net.ipv6.conf.main.accept_redirects" = 0;
        })
      ];
    };
}
