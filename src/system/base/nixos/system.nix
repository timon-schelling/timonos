{ config, lib, ... }:

{
  system.stateVersion = config.opts.system.stateVersion;
  nixpkgs.hostPlatform = config.opts.system.platform;
  nixpkgs.config.allowUnfree = true;

  # needed for uid/gid persistence in nixos
  platform.system.persist.folders = [
    { directory = "/var/lib/nixos"; initrd = true; }
  ];

  # needed for systemd and some programs that need a persistent machine id
  platform.system.persist.files = [
    { file = "/etc/machine-id"; method = "symlink"; initrd = true; }
  ];
  boot.initrd.systemd.tmpfiles.settings.persist = lib.mkIf config.platform.system.filesystem.persist.enable {
    "/sysroot/persist/system/etc/machine-id".f = {
      mode = "0444";
      argument = "uninitialized";
    };
  };
  systemd.services.systemd-machine-id-commit = lib.mkIf config.platform.system.filesystem.persist.enable {
    unitConfig.ConditionPathIsMountPoint = [ "" "/persist/system/etc/machine-id" ];
    serviceConfig.ExecStart = [ "" "${lib.getExe' config.systemd.package "systemd-machine-id-setup"} --commit --root /persist/system" ];
  };
}
