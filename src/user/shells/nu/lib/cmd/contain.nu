# TODO: remove replace-fuse-indirections once a real solution for https://gitlab.com/virtio-fs/virtiofsd/-/issues/206 is implemented

module contain-nix-helper {
    def parent-mount [path, disks?] {
        let mounts = if ($disks != null) { $disks } else { sys disks }
        (generate {|e|
            if ($e != '/') {
                let parent = $e | path dirname;
                {out: $parent, next: $parent}
            } else { {} }
        } $path)
        | each { |path|
        $mounts | where { $in.mount == $path }
        } | where { ($in | length) > 0 } | get 0.0
    }

    def resolve-fuse-indirections [path] {
        let path = $path | path expand;
        let mounts = sys disks | select mount device type
        mut parent_mount = parent-mount $path $mounts
        mut rewrite = null;
        while ($parent_mount.type == 'fuse' and $parent_mount.mount != '/') {
            $rewrite = $parent_mount.device | path join ($path | path relative-to $parent_mount.mount)
            $parent_mount = parent-mount $rewrite $mounts;
        }
        $rewrite
    }

    def args-to-replace-fuse-indirections [config] {
        $config | get filesystem.shares.source | enumerate | each { |it|
            resolve-fuse-indirections $it.item | do {
                if ($in != null) {
                    {
                        position: $it.index,
                        path: $it.item,
                        rewrite: $in,
                    }
                } else { null }
            }
        } | each { ["-c", $"filesystem.shares[($in.position)].source", $in.rewrite] } | flatten
    }

    export def extra-args [config] {
        args-to-replace-fuse-indirections $config
    }
}

def --env --wrapped contain-nix [flake, name, --build(-b), ...args] {
    use contain-nix-helper extra-args;

    let config_path_env = $"CONTAIN_CONFIG_PATH_($name | str screaming-snake-case)";
    let flake = $flake | str replace "~" $env.HOME
    let env_exists = $config_path_env in $env
    if (not $env_exists or $build) {
        let config_path = nix build --no-link --print-out-paths $"($flake)#nixosConfigurations.($name).config.contain.out" | lines | get 0
        load-env { $"($config_path_env)": $config_path }
    }
    let config_path = $env | get $config_path_env
    let config_json = open $config_path
    let extra_args = extra-args $config_json
    contain start $config_path ...$extra_args ...$args
}
