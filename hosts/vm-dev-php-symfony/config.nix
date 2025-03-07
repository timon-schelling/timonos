{ pkgs, lib, config, ... }:

{
  imports = [
    ../vm-dev/config.nix
  ];

  vm.config.filesystem.disks = [
    {
      source = ".vm/persist.disk.qcow2";
      tag = "persist";
      size = 30000;
    }
  ];

  fileSystems."/persist" = {
    device = "/dev/disk/by-id/virtio-persist";
    fsType = "btrfs";
    neededForBoot = true;
    autoFormat = true;
    options = [
      "x-initrd.mount"
      "defaults"
      "x-systemd.requires=systemd-modules-load.service"
    ];
  };

  opts.system.filesystem.type = lib.mkForce "ephemeral";

  opts.users.timon.home.persist.state.folders = [ ".cache/composer" ];
  opts.system.persist.folders = [
    "/var/lib/docker"
  ];
  virtualisation.docker.enable = true;
  users.users.timon.extraGroups = [ "docker" ];
  environment.systemPackages = [
    (pkgs.php84.buildEnv {
      extensions = { enabled, all }:
        enabled ++ (with all; [
          bcmath
          gd
          intl
          pdo_mysql
          zip
          simplexml
        ]);
    })
    pkgs.php84Packages.composer
    (pkgs.callPackage ./symfony-cli-package.nix {})
  ];
}
