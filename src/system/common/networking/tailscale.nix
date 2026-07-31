{ config, lib, ... }:

let
  cfg = config.opts.system.network.tailscale;
in
{
  options.opts.system.network.tailscale.enable = lib.mkEnableOption "Enable Tailscale";

  config = lib.mkIf cfg.enable {
    platform.system.persist.folders = [ "/var/lib/tailscale" ];

    services.tailscale = {
      enable = true;
      openFirewall = true;
      useRoutingFeatures = "client";
    };

    networking.firewall.trustedInterfaces = [ "tailscale0" ];
  };
}
