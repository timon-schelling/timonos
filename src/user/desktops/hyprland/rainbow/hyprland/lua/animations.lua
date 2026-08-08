hl.config({
  animations = {
    enabled = true,
  },
})

hl.curve("windows", { type = "bezier", points = { { 0.05, 0.9 }, { 0.1, 1.05 } } })
hl.curve("liner", { type = "bezier", points = { { 0, 0 }, { 1, 1 } } })

hl.animation({ leaf = "windows", enabled = true, speed = 7, bezier = "windows" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 7, bezier = "default", style = "popin 80%" })
hl.animation({ leaf = "border", enabled = true, speed = 10, bezier = "default" })
hl.animation({ leaf = "fade", enabled = true, speed = 7, bezier = "default" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 6, bezier = "default" })

hl.animation({ leaf = "borderangle", enabled = true, speed = 100, bezier = "liner", style = "loop" })
