local theme = require("theme")

hl.env("XDG_SESSION_TYPE", "wayland")

hl.config({
  general = {
    gaps_in = 5,
    gaps_out = 7,
    border_size = 4,

    col = {
      active_border = theme.borderActive,
      inactive_border = theme.borderInactive,
    },

    layout = "dwindle",

    resize_on_border = true,
  },

  decoration = {
    rounding = 10,
    shadow = {
      enabled = false,
    },
  },

  dwindle = {
    preserve_split = true,
  },

  input = {
    -- scrolllock as the compose key, needed by keyd
    kb_options = "compose:sclk",

    follow_mouse = 1,
    touchpad = {
      natural_scroll = true,
    },
    sensitivity = 0,
  },

  cursor = {
    inactive_timeout = 3,
    no_hardware_cursors = true,
  },

  misc = {
    disable_hyprland_logo = true,
    disable_splash_rendering = true,
    background_color = theme.background,
    enable_anr_dialog = false,
  },

  render = {
    direct_scanout = false,
    cm_sdr_eotf = "3",
  },

  ecosystem = {
    no_update_news = true,
    no_donation_nag = true,
  },

  debug = {
    disable_logs = false,
  },
})

hl.gesture({
  fingers = 4,
  direction = "horizontal",
  action = "workspace",
})
