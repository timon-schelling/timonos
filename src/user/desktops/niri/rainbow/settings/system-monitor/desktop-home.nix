{  pkgs, lib, config, ... }:

{
  home.packages = [
    (pkgs.nu.writeScriptBin "system-monitor" ''
      def --wrapped main [...args] {
          ${lib.getExe pkgs.foot} -o font=monospace:size=14 -o colors.background=151515 ${lib.getExe pkgs.btop}
      }
    '')
  ];
}
