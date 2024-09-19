{ pkgs, ... }:

{
  # for unity games set data folder with `XDG_CONFIG_HOME=~/.local/share/Steam/data %command%` in steam launch options
  persist.state.folders = [ ".local/share/Steam" ];
  home.packages = [ pkgs.steam ];
}
