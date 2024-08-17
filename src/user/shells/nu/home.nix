{ pkgs, lib, ... }:

{
  platform.user.persist = {
    files = [
      ".config/nushell/history.txt"
      ".cache/tere/history.json"
    ];
    folders = [
      ".local/share/atuin"
    ];
  };

  programs.nushell = {
    enable = true;
    envFile.source = ./env.nu;
    configFile.source = ./config.nu;
  };
  xdg.configFile."nushell/lib" = {
    source = ./lib;
    recursive = true;
  };

  home.packages = with pkgs; [
    bat
    tere
    fd
    ripgrep
    skim
  ];

  programs.starship = {
    enable = true;
    enableNushellIntegration = true;
    settings = (builtins.fromTOML (builtins.readFile ./starship.toml));
  };

  programs.carapace = {
    enable = true;
    enableNushellIntegration = true;
  };

  programs.atuin = {
    enable = true;
    enableNushellIntegration = true;
    flags = [ "--disable-up-arrow" "--disable-ctrl-r" ];
    settings = {
      style = "compact";
    };
  };
  programs.nushell.extraEnv = ''
    $env.ATUIN_NOBIND = true
  '';
  programs.nushell.extraConfig = lib.mkAfter ''
    $env.config = (
      $env.config | upsert keybindings (
        $env.config.keybindings
        | append {
          name: atuin
          modifier: shift
          keycode: up
          mode: [emacs, vi_normal, vi_insert]
          event: { send: executehostcommand cmd: (do { _atuin_search_cmd }) }
        }
      )
    )
  '';
}
