{  pkgs, lib, config, ... }:

{
  home.packages = [
    pkgs.brightnessctl
    (pkgs.nu.writeScriptBin "monitor-set-brightness" ''
      def --wrapped main [...args] {
        ls /sys/class/backlight | get name | path basename | par-each {
          ${pkgs.brightnessctl}/bin/brightnessctl --device $in set ...$args
        }
      }
    '')
  ];
}
