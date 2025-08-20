if ((not ('DISABLE_PROMPT' in $env)) or $env.DISABLE_PROMPT != "TRUE") {
    $env.STARSHIP_SHELL = "nu"
    $env.STARSHIP_SESSION_KEY = (random chars -l 16)
    $env.PROMPT_MULTILINE_INDICATOR = (starship prompt --continuation)
    $env.PROMPT_INDICATOR = ""
    $env.PROMPT_COMMAND = { ||
        let width = (term size).columns
        starship prompt $"--cmd-duration=($env.CMD_DURATION_MS)" $"--status=($env.LAST_EXIT_CODE)" $"--terminal-width=($width)"
    }

    let has_config_items = (not ($env | get -o config | is-empty))

    $env.config = if $has_config_items {
        $env.config | upsert render_right_prompt_on_last_line true
    } else {
        {render_right_prompt_on_last_line: true}
    }

    $env.PROMPT_COMMAND_RIGHT = { ||
        let width = (term size).columns
        starship prompt --right $"--cmd-duration=($env.CMD_DURATION_MS)" $"--status=($env.LAST_EXIT_CODE)" $"--terminal-width=($width)"
    }
}
