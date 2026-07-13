# TODO: remove replace-fuse-indirections once a real solution for https://gitlab.com/virtio-fs/virtiofsd/-/issues/206 is implemented

module contain-nix-helper {
    def parent-mount [path, disks?] {
        let mounts = $disks | default (sys disks)
        (generate {|e|
            if ($e != '/') {
                {out: $e, next: ($e | path dirname)}
            } else { {out: '/'} }
        } $path)
        | each {|p| $mounts | where mount == $p }
        | where { ($in | length) > 0 }
        | get 0.0
    }

    def resolve-fuse-indirections [path] {
        let mounts = sys disks | select mount device type
        mut current = $path | path expand
        mut rewritten = false
        mut parent_mount = parent-mount $current $mounts
        mut depth = 0
        while ($parent_mount.type == 'fuse' and $parent_mount.mount != '/') {
            if ($depth >= 42) {
                error make {msg: $"too many FUSE indirections while resolving ($path)"}
            }
            $current = $parent_mount.device | path join ($current | path relative-to $parent_mount.mount)
            $parent_mount = parent-mount $current $mounts
            $rewritten = true
            $depth += 1
        }
        if $rewritten { $current } else { null }
    }

    def args-to-replace-fuse-indirections [config] {
        $config
        | get -o filesystem.shares.source
        | default []
        | enumerate
        | each { |it|
            resolve-fuse-indirections $it.item | do {
                if ($in != null) {
                    {
                        position: $it.index,
                        path: $it.item,
                        rewrite: $in,
                    }
                } else { null }
            }
        }
        | each { ["-c", $"filesystem.shares[($in.position)].source", $in.rewrite] }
        | flatten
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
