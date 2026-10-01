{ lib, pkgs, ... }:

{
  services.shairport-sync = {
    enable = true;
    openFirewall = true;
    package = pkgs.shairport-sync.override {
      enableAirplay2 = false;
      enableAlsa = false;
      enablePipewire = true;
      enablePulse = false;
      enableSndio = false;
      enableAo = false;
      enableJack = false;
      enableSoundio = false;
      enablePipe = false;
      enableStdout = false;
      enableMetadata = false;
      enableMpris = false;
      enableDbus = false;
      enableMqttClient = false;
      enableConvolution = false;
    };
    settings = {
      general = {
        name = "streamer-0";
        output_backend = "pipewire";
      };
      diagnostics.log_verbosity = 0;
    };
  };
  systemd.services.shairport-sync = {
    after = [ "pipewire.socket" ];
    wants = [ "pipewire.socket" ];
  };
  users.users.shairport.extraGroups = lib.mkForce [ "pipewire" ];
}
