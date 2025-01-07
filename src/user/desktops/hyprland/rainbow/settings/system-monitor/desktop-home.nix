{  pkgs, lib, config, ... }:

{
  home.packages = [
    (pkgs.nu.writeScriptBin "system-monitor" ''
      def --wrapped main [...args] {
          ${pkgs.foot}/bin/foot -o font=monospace:size=15 -o colors.background=151515 ${pkgs.btop}/bin/btop
      }
    '')
  ];
}
