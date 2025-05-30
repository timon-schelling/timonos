def --env contain-nix [flake, name, --build(-b)] {
    let config_path_env = $"CONTAIN_CONFIG_PATH_($name | str screaming-snake-case)";
    let flake = $flake | str replace "~" $env.HOME
    let env_exists = $config_path_env in $env
    if (not $env_exists or $build) {
        let config_path = nix build --no-link --print-out-paths $"($flake)#nixosConfigurations.($name).config.contain.out" | lines | get 0
        load-env { $"($config_path_env)": $config_path }
    }
    contain start ($env | get $config_path_env)
}
