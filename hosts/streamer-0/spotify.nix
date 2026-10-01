{ lib, pkgs, ... }:

let
  librespot = pkgs.librespot.override {
    withALSA = false;
    withRodio = false;
  };
in
{
  systemd.services.librespot = {
    description = "Spotify Connect (librespot)";
    wantedBy = [ "multi-user.target" ];
    after = [
      "network-online.target"
      "pipewire-pulse.socket"
      "avahi-daemon.service"
    ];
    wants = [
      "network-online.target"
      "pipewire-pulse.socket"
    ];
    serviceConfig = {
      ExecStart = lib.concatStringsSep " " [
        (lib.getExe librespot)
        "--name streamer-0"
        "--device-type speaker"
        "--backend pulseaudio"
        "--bitrate 320"
        "--zeroconf-port 5030"
        "--initial-volume 50"
        "--volume-ctrl log"
        "--cache /var/cache/librespot"
        "--disable-audio-cache"
      ];
      DynamicUser = true;
      CacheDirectory = "librespot";
      SupplementaryGroups = [ "pipewire" ];
      Restart = "on-failure";
      RestartSec = 5;
    };
  };

  networking.firewall.allowedTCPPorts = [ 5030 ];
}
