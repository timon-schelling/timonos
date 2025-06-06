{ pkgs, config, lib, ... }:

{
  programs.eww = {
    enable = true;
    configDir = ./.;
  };

  home.packages = [
    (pkgs.nu.writeScriptBin "control-panel-toggle" ''
      let screen_id = hyprctl activeworkspace -j | from json | get monitorID
      eww open --screen $screen_id --toggle control-panel
    '')
  ];
}
