{ lib, ... }: {
  opts.user.profiles.default.enable = lib.mkDefault true;
  opts.user.apps = {
    editor = {
      lapce.enable = lib.mkDefault true;
    };
    browser = {
      chromium.enable = lib.mkDefault true;
      zen-browser.enable = lib.mkDefault true;
      tor-browser.enable = lib.mkDefault true;
    };
    filemanager = {
      gnome.enable = lib.mkDefault true;
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
}