{ pkgs, config, lib, ... }:

let
  ddcciFix = pkgs.nu.writeScript "hyprland-monitor-fix-ddcci-nvidia" ''
    sleep 5sec; monitor-fix-ddcci-nvidia
  '';
in
{
  wayland.windowManager.hyprland = {
    enable = true;
    xwayland.enable = true;
    systemd = {
      enable = true;
      variables = [ "--all" ];
    };

    configType = "lua";

    settings.env = lib.mapAttrsToList
      (name: value: { _args = [ name (builtins.toString value) ]; })
      config.home.sessionVariables;

    extraLuaFiles = {
      settings = ./lua/settings.lua;
      animations = ./lua/animations.lua;
      monitors = ./lua/monitors.lua;
      rules = ./lua/rules.lua;
      binds = ./lua/binds.lua;
      autostart = ./lua/autostart.lua;

      theme = {
        content = ./lua/theme.lua;
        autoLoad = false;
      };

      nix = {
        autoLoad = false;
        content = "return " + lib.generators.toLua { } {
          autostart =
            lib.optional
              config.opts.system.hardware.gpu.nvidia.monitorDdcciFixEnable
              "${ddcciFix}";
        };
      };
    };
  };
}
