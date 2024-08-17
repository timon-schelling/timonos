local wezterm = require 'wezterm'
return {
    front_end = 'WebGpu',
    enable_wayland = false, -- TODO: set to true after nvidia fix
    window_decorations = "NONE",
    default_prog = { 'nu' },
    font = wezterm.font 'JetBrains Mono',
    font_size = 15.0,
    color_scheme = 'theme',
    initial_cols = 98,
    initial_rows = 32,
    hide_tab_bar_if_only_one_tab = true,
    window_close_confirmation = 'NeverPrompt',
    keys = {
        {
            key = 'e',
            mods = 'CTRL',
            action = wezterm.action.ShowLauncher,
        },
        {
            key = 't',
            mods = 'CTRL',
            action = wezterm.action.SpawnCommandInNewTab {},
        },
        {
            key = 'w',
            mods = 'CTRL',
            action = wezterm.action.CloseCurrentTab {
                confirm = false,
            },
        },
    },
    check_for_updates = false,

    -- needed under wayland compositors that hide the mouse cursor see https://github.com/wez/wezterm/issues/5071
    hide_mouse_cursor_when_typing = false,
}
