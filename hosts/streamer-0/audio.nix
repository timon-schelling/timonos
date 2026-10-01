{ lib, pkgs, ... }:

{
  systemd.services = lib.genAttrs [ "pipewire" "pipewire-pulse" ] (_: {
    serviceConfig = {
      LimitRTPRIO = 95;
      LimitMEMLOCK = "infinity";
    };
  });

  services.pipewire = {
    systemWide = true;
    alsa.support32Bit = lib.mkForce false;
    jack.enable = lib.mkForce false;
    extraLv2Packages = lib.mkForce [ ];

    extraConfig.pipewire."10-clock" = {
      "context.properties" = {
        "default.clock.rate" = 44100;
        "default.clock.allowed-rates" = [ 44100 ];
        "default.clock.quantum" = 2048;
        "default.clock.min-quantum" = 1024;
        "default.clock.max-quantum" = 8192;
      };
    };
    extraConfig.pipewire-pulse."10-buffers" = {
      "pulse.properties" = {
        "pulse.min.req" = "4096/44100";
        "pulse.default.req" = "16384/44100";
        "pulse.min.quantum" = "2048/44100";
      };
    };
    extraConfig.pipewire."10-raop-discover" = lib.mkForce { };
    raopOpenFirewall = lib.mkForce false;

    wireplumber.extraConfig."10-dac" = {
      "monitor.alsa.rules" = [
        {
          matches = [ { "node.name" = "~alsa_output.*"; } ];
          actions.update-props = {
            "audio.format" = "S32LE";
            "audio.rate" = 44100;
            "audio.allowed-rates" = [ 44100 ];
            "session.suspend-timeout-seconds" = 0;
          };
        }
      ];
    };

    package =
      let
        disabled = [
          "ffmpeg"
          "pw-cat-ffmpeg"
          "gstreamer"
          "gstreamer-device-provider"
          "libmysofa"
          "libcamera"
          "echo-cancel-webrtc"
        ];
        droppedInputs = [
          "ffmpeg-headless"
          "gstreamer"
          "gst-plugins-base"
          "libmysofa"
          "libcamera"
          "webrtc-audio-processing"
          "ldacbt"
          "modemmanager"
        ];
        isDisabledFlag = f: lib.any (k: lib.hasPrefix "-D${k}=" f) disabled;
      in
      (pkgs.pipewire.override {
        bluezSupport = false;
        rocSupport = false;
        vulkanSupport = false;
        x11Support = false;
        ffadoSupport = false;
      }).overrideAttrs
        (old: {
          buildInputs = lib.filter (p: !(lib.elem (lib.getName p) droppedInputs)) old.buildInputs;
          mesonFlags = (lib.filter (f: !(isDisabledFlag f)) old.mesonFlags) ++ map (k: "-D${k}=disabled") disabled;
        });
  };
}
