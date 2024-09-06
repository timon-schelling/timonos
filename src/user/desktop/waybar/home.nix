{ pkgs, inputs, config, lib, ... }:

{
  home.packages = [
    (pkgs.waybar)
    (pkgs.nu.writeScriptBin "waybar-toggle" (builtins.readFile ./toggle.nu))
  ];

  xdg.configFile."waybar/config".source = ./config.jsonc;
  xdg.configFile."waybar/style.css".source = ./style.css;
}
