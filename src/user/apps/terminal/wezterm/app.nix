{ pkgs, ... }:

{
  home.packages = [
    pkgs.wezterm
  ];

  xdg.configFile."wezterm/wezterm.lua".source = ./config.lua;
  xdg.configFile."wezterm/colors/theme.toml".source = ./theme.toml;
}
