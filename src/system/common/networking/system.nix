{ config, lib,  ... }:

{

  imports = [
    ./wifi.nix
    ./route-via-gateway.nix
  ];

  networking = {
    hostName = config.opts.system.host;
    nameservers = [ "1.1.1.1#one.one.one.one" "1.0.0.1#one.one.one.one" ];
    useNetworkd = true;
    networkmanager.enable = lib.mkOverride 900 false;
  };

  services.resolved = {
    enable = true;
    settings = {
      Resolve = {
        DNSSEC = true;
        Domains = [ "~." ];
        FallbackDNS = [ "1.1.1.1#one.one.one.one" "1.0.0.1#one.one.one.one" ];
        DNSOverTLS = "true";
      };
    };
  };

  systemd.network = {
    netdevs = {
      "10-bond-main" = {
        netdevConfig = {
          Kind = "bond";
          Name = "main";
        };
        bondConfig = {
          Mode = "active-backup";
          MIIMonitorSec="0.100s";
          PrimaryReselectPolicy="better";
        };
      };
    };
    networks = {
      "30-en-all" = {
        matchConfig.Name = "en*";
        networkConfig.Bond = "main";
        networkConfig.PrimarySlave = true;
      };

      "30-eth-all" = {
        matchConfig.Name = "eth*";
        networkConfig.Bond = "main";
        networkConfig.PrimarySlave = true;
      };

      "30-wl-all" = {
        matchConfig.Name = "wl*";
        networkConfig.Bond = "main";
      };

      "40-main" = {
        matchConfig.Name = "main";
        linkConfig.RequiredForOnline = "carrier";
        networkConfig.DHCP = "yes";
      };
    };
  };

  systemd.network.wait-online.enable = false;
}
