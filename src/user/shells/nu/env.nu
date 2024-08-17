$env.ENV_CONVERSIONS = {
    "PATH": {
        from_string: { |s| $s | split row (char esep) | path expand -n }
        to_string: { |v| $v | path expand -n | str join (char esep) }
    }
}

$env.NU_LIB_DIRS = [
    $"($env.HOME)/.config/nushell/lib"
]

$env.NU_PLUGIN_DIRS = [
    $"($env.HOME)/.config/nushell/plugins"
]
