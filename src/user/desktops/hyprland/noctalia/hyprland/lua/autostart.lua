local nix = require("nix")

hl.on("hyprland.start", function()
  for _, cmd in ipairs(nix.autostart) do
    hl.exec_cmd(cmd)
  end
end)
