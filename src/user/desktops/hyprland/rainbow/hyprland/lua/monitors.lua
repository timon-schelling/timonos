-- TODO: monitors should be set per host

-- desktop
hl.monitor({ output = "DP-3", mode = "2560x1440", position = "1200x250", scale = 1 })
hl.monitor({ output = "DP-2", mode = "1920x1200", position = "0x0", scale = 1, transform = 1 })
hl.monitor({ output = "DP-1", mode = "1920x1200", position = "3760x0", scale = 1, transform = 1 })

-- laptop
hl.monitor({ output = "eDP-1", mode = "1920x1200", position = "0x0", scale = 1 })

-- default
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = "auto" })

for _, name in ipairs({
  "wacom-co.-ltd.-wacom-one-pen-tablet-medium",
  "wacom-one-pen-tablet-medium",
}) do
  hl.device({
    name = name,
    output = "DP-3",
    active_area_size = { 216, 121.5 },
    active_area_position = { 0, 6.75 },
  })
end
