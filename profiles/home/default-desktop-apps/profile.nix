{ lib, ... }: {
  opts.user.apps = {
    terminal = {
      rio.enable = lib.mkDefault true;
    };
    settings = {
      wifi.enable = lib.mkDefault true;
      audio.enable = lib.mkDefault true;
    };
    editor = {
      vscode.enable = lib.mkDefault true;
    };
    browser = {
      firefox.enable = lib.mkDefault true;
    };
    filemanager = {
      gnome.enable = lib.mkDefault true;
    };
  };
}
