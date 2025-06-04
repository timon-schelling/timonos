{ config, lib,... }:

let
  cfg = config.opts.system.virtualization.contain;
in
{
  config = lib.mkMerge [
    (lib.mkIf (cfg.enable) {
        platform.user.persist.folders = [ ".local/share/contain"];
    })
  ];
}
