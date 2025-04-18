{ config, inputs, lib, ... }:

{
  imports = [
    inputs.disko.nixosModules.default
  ];

  config = lib.mkIf config.platform.system.filesystem.drives.enable {
    disko.devices = {
      disk.main = {
        device = config.opts.system.filesystem.drive;
        type = "disk";
        content = {
          type = "gpt";
          partitions = lib.mkMerge [
            {
              esp = {
                name = "ESP";
                size = "500M";
                type = "EF00";
                content = {
                  type = "filesystem";
                  format = "vfat";
                  mountpoint = "/boot";
                };
              };
              root = {
                name = "root";
                size = "100%";
                content = {
                  type = "lvm_pv";
                  vg = "root_vg";
                };
              };
            }
            (lib.mkIf config.opts.system.filesystem.swap.enable {
              swap = {
                size = config.opts.system.filesystem.swap.size;
                content = {
                  type = "swap";
                  resumeDevice = true;
                };
              };
            })
          ];
        };
      };
      lvm_vg = {
        root_vg = {
          type = "lvm_vg";
          lvs = {
            root = {
              size = "100%FREE";
              content = {
                type = "btrfs";
                extraArgs = [ "-f" ];
                subvolumes = {
                  "/root" = {
                    mountpoint = "/";
                  };
                  "/persist" = {
                    mountOptions = [ "subvol=persist" "noatime" ];
                    mountpoint = "/persist";
                  };
                  "/nix" = {
                    mountOptions = [ "subvol=nix" "noatime" ];
                    mountpoint = "/nix";
                  };
                  "/old" = {
                    mountOptions = [ "subvol=old" "noatime" ];
                    mountpoint = "/old";
                  };
                };
              };
            };
          };
        };
      };
    };

    assertions = [
      {
        assertion = !(config.opts.system.filesystem.drive == "");
        message = ''
          You must specify a drive for the root filesystem
          when using the "${config.opts.system.filesystem.type}" filesystem type
        '';
      }
    ];
  };
}
