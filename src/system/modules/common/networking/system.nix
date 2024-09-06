{ config, ... }:

{

  imports = [
    ./wifi.nix
  ];

  networking = {
    hostName = config.opts.system.host;
    nameservers = [ "1.1.1.1#one.one.one.one" "1.0.0.1#one.one.one.one" ];
    useNetworkd = true;
  };

  services.resolved = {
    enable = true;
    dnssec = "true";
    domains = [ "~." ];
    fallbackDns = [ "1.1.1.1#one.one.one.one" "1.0.0.1#one.one.one.one" ];
    dnsovertls = "true";
  };

  systemd.network.wait-online.enable = false;
}
