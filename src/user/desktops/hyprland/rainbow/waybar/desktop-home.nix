{ pkgs, lib, ... }:

let
  settings = {
    layer = "top";
    margin-bottom = 0;
    margin-left = 0;
    margin-right = 0;
    margin-top = 0;
    spacing = 0;
    modules-center = [ "clock" ];
    modules-left = [ "hyprland/workspaces" ];
    modules-right = [ "battery" "network" "cpu" "memory" "disk" "group/power-menu" ];

    "hyprland/workspaces" = {
      active-only = false;
      all-outputs = false;
      format = "{}";
      format-icons = {
        active = "";
        default = "";
        urgent = "";
      };
      on-click = "activate";
      on-scroll-down = "hyprctl dispatch workspace r-1";
      on-scroll-up = "hyprctl dispatch workspace r+1";
    };

    clock = {
      format = "{:%Y-%m-%d %H:%M:%S}";
      interval = 1;
      timezone = "Europe/Berlin";
    };

    battery = {
      format = "{icon} {capacity:02}";
      format-charging = " {capacity:02}";
      format-full = " {capacity:02}";
      format-icons = [ "" "" "" "" "" ];
      format-plugged = " {capacity:02}";
      format-time = " {H}:{m}";
      tooltip-format = ''
        󱎫{time}
         {power:0.1f}W
         {cycles}'';
      interval = 1;
      states = {
        critical = 15;
        warning = 30;
      };
    };

    network = {
      format = "󰛳";
      format-ethernet = "󰈀";
      format-wifi = " {signalStrength:02}";
      format-disconnected = "󰍸";
      tooltip-format = ''
        󰩟 {ipaddr}
        󰑩 {gwaddr}
        󰈀 {ifname}
         {bandwidthDownBits}
         {bandwidthUpBits}'';
      tooltip-format-ethernet = ''
        󰩟 {ipaddr}
        󰑩 {gwaddr}
        󰈀 {ifname}
         {bandwidthDownBits}
         {bandwidthUpBits}'';
      tooltip-format-wifi = ''
        󰩟 {ipaddr}
        󰑩 {gwaddr}
        󰈀 {ifname}
         {bandwidthDownBits}
         {bandwidthUpBits}
        󰿀 {essid}
        󰤥 {signalStrength}%
        󰐻 {frequency}MHz'';
      tooltip-format-disconnected = "󰍸 Disconnected";
      on-click = "settings-wifi";
    };

    cpu = {
      format = " {usage:02}";
      interval = 1;
    };

    memory = {
      format = " {percentage:02}";
      interval = 1;
    };

    disk = {
      format = " {percentage_used:02}";
      interval = 30;
      path = "/";
    };

    "group/power-menu" = {
      drawer = {
        children-class = "not-memory";
        transition-duration = 250;
        transition-left-to-right = true;
      };
      modules = [ "custom/poweroff" "custom/reboot" "custom/logout" ];
      orientation = "inherit";
    };
    "custom/suspend" = {
      format = "󰒲";
      on-click = "systemctl suspend";
      tooltip = false;
    };
    "custom/hibernate" = {
      format = "󰤄";
      on-click = "systemctl hibernate";
      tooltip = false;
    };
    "custom/logout" = {
      format = "󰍃";
      on-click = "hyprctl dispatch exit";
      tooltip = false;
    };
    "custom/reboot" = {
      format = "󰑓";
      on-click = "systemctl reboot";
      tooltip = false;
    };
    "custom/poweroff" = {
      format = "";
      on-click = "systemctl poweroff";
      tooltip = false;
    };

    pulseaudio = {
      format = "{icon} {volume}%";
      format-bluetooth = "{volume}% {icon} {format_source}";
      format-bluetooth-muted = " {icon} {format_source}";
      format-icons = {
        car = " ";
        default = [ " " " " " " ];
        hands-free = " ";
        headphone = " ";
        headset = " ";
        phone = " ";
        portable = " ";
      };
      format-muted = " {format_source}";
      format-source = "{volume}% ";
      format-source-muted = "";
      on-click = "pavucontrol";
    };

    bluetooth = {
      format = " {status}";
      format-disabled = "";
      format-no-controller = "";
      format-off = "";
      interval = 30;
      on-click = "blueman-manager";
    };

    idle_inhibitor = {
      format = "{icon}";
      format-icons = {
        activated = "";
        deactivated = "";
      };
      on-click-right = "hyprlock";
      tooltip = true;
    };
  };
in
{
  home.packages = [
    (pkgs.waybar)
    (pkgs.nu.writeScriptBin "waybar-toggle" ''
      let waybar_processes = (ps | filter {
          ($in.name | str contains -i waybar) and not ($in.name | str contains -i waybar-toggle)
      })
      if ($waybar_processes | is-empty) {
          hyprctl dispatch exec waybar
      } else {
          $waybar_processes | each { kill $in.pid }
      }
    '')
  ];

  xdg.configFile."waybar/config".source =
    ((pkgs.formats.json { }).generate "waybar-config" settings);
  xdg.configFile."waybar/style.css".source = ./style.css;
}
