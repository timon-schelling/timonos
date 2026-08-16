{  pkgs, lib, config, ... }:

{
  home.packages = [
    pkgs.brightnessctl
    (pkgs.nu.writeScriptBin "monitor-set-brightness" ''
      def --wrapped main [...args] {
        ls /sys/class/backlight | get name | path basename | par-each {
          ${lib.getExe pkgs.brightnessctl} --device $in set ...$args
        }
      }
    '')
  ];
}
