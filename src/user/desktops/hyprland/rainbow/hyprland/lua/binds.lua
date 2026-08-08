local mainMod = "SUPER"

hl.bind(mainMod .. " + left", hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + up", hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + down", hl.dsp.focus({ direction = "down" }))

hl.bind(mainMod .. " + Q", hl.dsp.window.close())
hl.bind(mainMod .. " + M", hl.dsp.window.fullscreen({ action = "toggle", mode = "fullscreen" }))
hl.bind(mainMod .. " + G", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + O", hl.dsp.layout("togglesplit"))
hl.bind(mainMod .. " + S", hl.dsp.window.pseudo())
hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen_state({ internal = -1, client = 3 }))

hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

hl.bind(mainMod .. " + CONTROL + SHIFT + right", hl.dsp.window.resize({ x = 20, y = 0, relative = true }), { repeating = true })
hl.bind(mainMod .. " + CONTROL + SHIFT + left", hl.dsp.window.resize({ x = -20, y = 0, relative = true }), { repeating = true })
hl.bind(mainMod .. " + CONTROL + SHIFT + up", hl.dsp.window.resize({ x = 0, y = -20, relative = true }), { repeating = true })
hl.bind(mainMod .. " + CONTROL + SHIFT + down", hl.dsp.window.resize({ x = 0, y = 20, relative = true }), { repeating = true })

hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })

hl.bind(mainMod .. " + SHIFT + right", hl.dsp.window.move({ direction = "right" }))
hl.bind(mainMod .. " + SHIFT + left", hl.dsp.window.move({ direction = "left" }))
hl.bind(mainMod .. " + SHIFT + up", hl.dsp.window.move({ direction = "up" }))
hl.bind(mainMod .. " + SHIFT + down", hl.dsp.window.move({ direction = "down" }))

-- TODO: use vdesks after plugin is fixed
-- hl.config({ plugin = { ["virtual-desktops"] = {
--   cycleworkspaces = 0,
--   notifyinit = 0,
--   -- rememberlayout = "monitors",
-- } } })
-- hl.bind(mainMod .. " + page_up", hl.dsp.global("prevdesk"))
-- hl.bind(mainMod .. " + page_down", hl.dsp.global("nextdesk"))
-- hl.bind(mainMod .. " + mouse_up", hl.dsp.global("prevdesk"))
-- hl.bind(mainMod .. " + mouse_down", hl.dsp.global("nextdesk"))
-- hl.bind(mainMod .. " + SHIFT + page_up", hl.dsp.global("movetoprevdesk"))
-- hl.bind(mainMod .. " + SHIFT + page_down", hl.dsp.global("movetonextdesk"))

hl.bind(mainMod .. " + page_up", hl.dsp.focus({ workspace = "m-1" }))
hl.bind(mainMod .. " + page_down", hl.dsp.focus({ workspace = "m+1" }))
hl.bind(mainMod .. " + mouse_up", hl.dsp.focus({ workspace = "m-1" }))
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "m+1" }))
hl.bind(mainMod .. " + SHIFT + page_up", hl.dsp.window.move({ workspace = "r-1" }))
hl.bind(mainMod .. " + SHIFT + page_down", hl.dsp.window.move({ workspace = "r+1" }))

hl.bind(mainMod .. " + V", hl.dsp.exec_cmd("clipboard-history"))

hl.bind(mainMod .. " + B", hl.dsp.exec_cmd("waybar-toggle"))

hl.bind("SUPER + SUPER_L", hl.dsp.exec_cmd("control-panel-toggle"))

hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("monitor-set-brightness +10%"), { repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("monitor-set-brightness 10-%"), { repeating = true })
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+ -l 2.0"), { repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%- -l 2.0"), { repeating = true })
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"))
hl.bind("Print", hl.dsp.exec_cmd("screenshot"))

hl.bind("ALT + space", hl.dsp.exec_cmd("anyrun"))

for _, app in ipairs({
  { "1", "ghostty" },
  { "2", "code" },
  { "3", "firefox" },
  { "4", "nautilus --new-window" },
  { "5", "bitwarden" },
  { "6", "rio" },
  { "7", "spotify" },
  { "8", "beeper" },
  -- { "9", "" },
  -- { "0", "" },
}) do
  hl.bind(mainMod .. " + " .. app[1], hl.dsp.exec_cmd(app[2]))
end

hl.bind(mainMod .. " + SHIFT + Q", hl.dsp.exit())
hl.bind(mainMod .. " + SHIFT + R", hl.dsp.force_renderer_reload())
