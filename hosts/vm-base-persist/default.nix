{ lib, pkgs, config, ... }:

{
  contain.config.filesystem.disks = [
    {
      tag = "persist";
      size = 30000;
    }
  ];

  fileSystems."/persist" = {
    device = "/dev/disk/by-id/virtio-persist";
    fsType = "ext4";
    neededForBoot = true;
    autoFormat = true;
    options = [
      "x-initrd.mount"
      "defaults"
      "x-systemd.requires=systemd-modules-load.service"
    ];
  };

  opts.system.filesystem.type = lib.mkForce "ephemeral";
}
