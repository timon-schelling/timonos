{ lib, config, ... }:

let
    resetRootScript = ''
        mkdir /btrfs_tmp
        mount /dev/root_vg/root /btrfs_tmp
        if [[ -e /btrfs_tmp/root ]]; then
            if [[ ! -e /btrfs_tmp/old ]]; then
                btrfs subvolume create /btrfs_tmp/old
            fi
            timestamp=$(date --date="@$(stat -c %Y /btrfs_tmp/root)" "+%Y-%m-%d_%H:%M:%S")
            mv /btrfs_tmp/root "/btrfs_tmp/old/$timestamp"
        fi

        delete_subvolume_recursively() {
            IFS=$'\n'
            for i in $(btrfs subvolume list -o "$1" | cut -f 9- -d ' '); do
                delete_subvolume_recursively "/btrfs_tmp/$i"
            done
            btrfs subvolume delete "$1"
        }

        for i in $(find /btrfs_tmp/old/ -maxdepth 1 -mtime +42); do
            delete_subvolume_recursively "$i"
        done

        btrfs subvolume create /btrfs_tmp/root
        umount /btrfs_tmp
    '';
in
lib.mkMerge [
    (lib.mkIf config.boot.initrd.systemd.enable ({
        boot.initrd.systemd.services."reset-root" = {
            description = "Reset root filesystem to a clean state on boot";
            wantedBy = [ "initrd-fs.target" ];
            wants = [ "dev-root_vg-root.device" ];
            after = [ "dev-root_vg-root.device" ];
            unitConfig.DefaultDependencies = false;
            serviceConfig = {
                Type = "oneshot";
                RemainAfterExit = true;
            };
            script = resetRootScript;
        };
    }))
    (lib.mkIf (!config.boot.initrd.systemd.enable) ({
        boot.initrd.postDeviceCommands = lib.mkAfter resetRootScript;
    }))
]
