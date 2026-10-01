{ lib, pkgs, ... }:

{
  services.pipewire = {
    systemWide = true;
    alsa.support32Bit = lib.mkForce false;
    jack.enable = lib.mkForce false;
    extraLv2Packages = lib.mkForce [ ];

    extraConfig.pipewire."10-clock" = {
      "context.properties" = {
        "default.clock.rate" = 44100;
        "default.clock.allowed-rates" = [ 44100 48000 ];
      };
    };

    wireplumber.extraConfig."10-dac" = {
      "monitor.alsa.rules" = [
        {
          matches = [ { "node.name" = "~alsa_output.*"; } ];
          actions.update-props = {
            "audio.format" = "S32LE";
            "audio.rate" = 44100;
            "audio.allowed-rates" = [ 44100 48000 ];
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
