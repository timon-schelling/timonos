{ lib, ... }: {
  opts.user.profiles = {
    default-desktop-apps.enable = lib.mkDefault true;
  };
  opts.user = {
    name = lib.mkDefault "Timon Schelling";
    email = lib.mkDefault "me@timon.zip";
    persist.data.folders = lib.mkDefault [
      "code"
      "data"
      "media"
      "tmp"
    ];
    desktops.hyprland.rainbow.enable = lib.mkDefault true;
    apps = {
      editor = {
        lapce.enable = lib.mkDefault true;
      };
      browser = {
        chromium.enable = lib.mkDefault true;
        zen-browser.enable = lib.mkDefault true;
        tor-browser.enable = lib.mkDefault true;
      };
      passwordmanager = {
        enpass.enable = lib.mkDefault true;
      };
      other = {
        beeper.enable = lib.mkDefault true;
        signal.enable = lib.mkDefault true;
        discord-webcord.enable = lib.mkDefault true;
        spotify.enable = lib.mkDefault true;
      };
    };
  };
}
