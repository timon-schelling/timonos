{ lib, ... }: {
  opts.user.profiles = {
    default-desktop-apps.enable = lib.mkDefault true;
  };
  opts.user = {
    name = lib.mkDefault "Timon";
    email = lib.mkDefault "me@timon.zip";
    persist = {
      data.folders = lib.mkDefault [
        "code"
        "data"
        "media"
        "tmp"
      ];
    };
    desktops.hyprland.rainbow.enable = lib.mkDefault true;
    apps = {
      editor = {
        zed.enable = lib.mkDefault true;
      };
      browser = {
        chromium.enable = lib.mkDefault true;
        tor-browser.enable = lib.mkDefault true;
      };
      passwordmanager = {
        bitwarden.enable = lib.mkDefault true;
      };
      media = {
        graphite.enable = lib.mkDefault true;
        gimp.enable = lib.mkDefault true;
        kdenlive.enable = lib.mkDefault true;
        obs-studio.enable = lib.mkDefault true;
        spotify.enable = lib.mkDefault true;
        music-player.enable = lib.mkDefault true;
      };
      utils = {
        rustdesk.enable = lib.mkDefault true;
        btop.enable = lib.mkDefault true;
      };
      other = {
        beeper.enable = lib.mkDefault true;
        signal.enable = lib.mkDefault true;
        # webcord.enable = lib.mkDefault true; TODO: fix webcord
      };
    };
    vcs.enable = lib.mkDefault true;
    podman.enable = lib.mkDefault true;
  };
}
