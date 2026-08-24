local theme = require("theme")

-- vms
hl.window_rule({
  name = "vm-border",
  match = { initial_title = [[\[vm.*\] - .*]] },
  border_color = theme.borderVm,
})

-- xwayland
hl.window_rule({
  name = "xwayland-border",
  match = { xwayland = true },
  border_color = theme.borderXwayland,
})

-- floating
hl.window_rule({
  name = "iwgtk-float",
  match = { class = "^(.*iwgtk)$" },
  float = true,
})
