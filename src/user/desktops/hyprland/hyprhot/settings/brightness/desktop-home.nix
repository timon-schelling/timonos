{  pkgs, lib, config, ... }:

{
  home.packages = [
    pkgs.brightnessctl
    (pkgs.nu.writeScriptBin "monitor-set-brightness" ''
      def --wrapped main [...args] {
        ${if config.opts.system.hardware.gpu.nvidia.monitorDdcciFixEnable then "monitor-fix-ddcci-nvidia" else ""}
        ls /sys/class/backlight | get name | path basename | par-each {
          ${pkgs.brightnessctl}/bin/brightnessctl --device $in set ...$args
        }
      }
    '')
  ];
}
