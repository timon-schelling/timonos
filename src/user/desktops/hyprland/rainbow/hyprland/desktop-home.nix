{ pkgs, config, lib, ... }:

{
  wayland.windowManager.hyprland = {
    enable = true;
    xwayland.enable = true;
    systemd = {
      enable = true;
      variables = [ "--all" ];
    };
    settings.env = lib.attrsets.mapAttrsToList (name: value: "${name},${builtins.toString value}") config.home.sessionVariables;
    extraConfig = ''

      #TODO: monitors should be set per host

      # desktop
      monitor = DP-3, 2560x1440, 1200x250, 1
      monitor = DP-2, 1920x1200, 0x0, 1, transform, 1
      monitor = DP-1, 1920x1200, 3760x0, 1, transform, 1

      # laptop
      monitor = eDP-1, 1920x1200, 0x0 ,1

      # other monitors
      monitor = ,preferred, auto, auto

      env = XDG_SESSION_TYPE,wayland

      cursor {
        inactive_timeout = 3
        no_hardware_cursors = true
      }

      input {
        # `compose:sclk` sets scrolllock as the compose key, needed by keyd
        kb_options = compose:sclk

        follow_mouse = 1
        touchpad {
            natural_scroll = yes
        }
        sensitivity = 0 # -1.0 - 1.0, 0 means no modification
      }

      ecosystem {
        no_update_news = true
        no_donation_nag = true
      }

      general {
        gaps_in = 5
        gaps_out = 7
        border_size = 4

        # col.active_border = rgba(33ccffee) rgba(00ff99ee) 45deg
        # col.active_border = rgba(0052a5ee) rgba(760060ee) 30deg
        # col.active_border = rgba(ffb500ee) rgba(760060ee) rgba(0052a5ee) 30deg
        # col.active_border = rgba(ee00acee) rgba(ffb500ee) rgba(760060ee) rgba(0052a5ee) 30deg
        # col.active_border = rgba(ffa200ee) rgba(b600a5ee) rgba(760060ee) rgba(0052a5ee) 30deg
        # col.active_border = rgba(ff9300ee) rgba(b600a5ee) rgba(760060ee) rgba(0052a5ee) 30deg
        # col.active_border = rgba(ff9300ee) rgba(6f004eee) rgba(6f004eee) rgba(0052a5ee) 30deg
        # col.active_border = rgba(ff9300ee) rgba(8f0064ee) rgba(8f0064ee) rgba(0052a5ee) 30deg
        # col.active_border = rgba(ff9300ee) rgba(ff9300ee) rgba(8f0064ee) rgba(8f0064ee) rgba(8f0064ee) rgba(0052a5ee) rgba(0052a5ee) rgba(0052a5ee) rgba(008c41ee) 30deg
        # col.active_border = rgba(ff9300ee) rgba(ff9300ee) rgba(8f0064ee) rgba(8f0064ee) rgba(8f0064ee) rgba(0052a5ee) rgba(0052a5ee) rgba(0052a5ee) rgba(04bf5bee) 30deg
        # col.active_border = rgba(8f0064ee) rgba(ff9300ee) rgba(ff9300ee) rgba(04bf5bee) rgba(04bf5bee) rgba(04bf5bee) rgba(029edbee) rgba(0052a5ee) 90deg
        col.active_border = rgba(8f0064ee) rgba(8f0064ee) rgba(ff9300ee) rgba(ff9300ee) rgba(04bf5bee) rgba(04bf5bee) rgba(04bf5bee) rgba(029edbee) rgba(0052a5ee) rgba(0052a5ee) 40deg
        # col.active_border = rgba(ff9300ee) rgba(8f0064ee) rgba(8f0064ee) rgba(8f0064ee) rgba(0052a5ee) rgba(0052a5ee) rgba(04bf5bee) 242deg
        # col.active_border = rgba(ff9300ee) rgba(8f0064ee) rgba(8f0064ee) rgba(8f0064ee) rgba(0052a5ee) rgba(0052a5ee) rgba(00a64dee) 242deg
        # col.active_border = rgba(ff9300ee) rgba(8f0064ee) rgba(8f0064ee) rgba(8f0064ee) rgba(0052a5ee) rgba(0052a5ee) rgba(00b849ee) 242deg
        # col.active_border = rgba(ff9300ee) rgba(8f0064ee) rgba(8f0064ee) rgba(8f0064ee) rgba(0052a5ee) rgba(0091ffee) 242deg
        # col.active_border = rgba(ff9300ee) rgba(8f0064ee) rgba(8f0064ee) rgba(8f0064ee) rgba(0052a5ee) 242deg
        # col.active_border = rgba(ff9300ee) rgba(8f0064ee) rgba(ff9300ee) rgba(8f0064ee) 242deg
        # col.active_border = rgba(ff9300ee) rgba(8f0064ee) 242deg
        # col.active_border = rgba(ff9300ee) rgba(8f0064ee) rgba(8f0064ee) rgba(8f0064ee) rgba(0052a5ee) 242deg
        # col.active_border = rgba(2cc966ee)
        # col.active_border = rgba(007621ee)

        # col.inactive_border = rgba(595959aa)
        col.inactive_border = rgba(393939ff)

        layout = dwindle

        resize_on_border = true
      }

      decoration {
        rounding = 10
        shadow {
          enabled = false
        }
      }

      animations {
        enabled = yes

        bezier = windows, 0.05, 0.9, 0.1, 1.05
        animation = windows, 1, 7, windows
        animation = windowsOut, 1, 7, default, popin 80%
        animation = border, 1, 10, default
        animation = borderangle, 1, 8, default
        animation = fade, 1, 7, default
        animation = workspaces, 1, 6, default

        bezier = liner, 0, 0, 1, 1
        animation = borderangle, 1, 400, liner, loop
        # animation = borderangle, 1, 200, liner, loop
        # animation = borderangle, 1, 50, liner, loop
        # animation = borderangle, 1, 1000, liner, loop
      }

      dwindle {
        pseudotile = yes
        preserve_split = yes
      }

      gestures {
        workspace_swipe = on
        workspace_swipe_fingers = 4
        workspace_swipe_forever = true
      }

      misc {
        disable_hyprland_logo = true
        disable_splash_rendering = true
        background_color = 0x161616
      }

      render {
        direct_scanout = no
      }

      $mainMod = SUPER

      bind = $mainMod, left, movefocus, l
      bind = $mainMod, right, movefocus, r
      bind = $mainMod, up, movefocus, u
      bind = $mainMod, down, movefocus, d

      bind = $mainMod, Q, killactive
      bind = $mainMod, M, fullscreen
      bind = $mainMod, G, togglefloating
      bind = $mainMod, O, togglesplit
      bind = $mainMod, S, pseudo
      bind = $mainMod, F, fullscreenstate, -1, 3

      bindm = $mainMod, mouse:273, resizewindow

      binde = $mainMod CONTROL SHIFT, right, resizeactive, 20 0
      binde = $mainMod CONTROL SHIFT, left, resizeactive, -20 0
      binde = $mainMod CONTROL SHIFT, up, resizeactive, 0 -20
      binde = $mainMod CONTROL SHIFT, down, resizeactive, 0 20

      bindm = $mainMod, mouse:272, movewindow

      bind = $mainMod SHIFT, right, movewindow, r
      bind = $mainMod SHIFT, left, movewindow, l
      bind = $mainMod SHIFT, up, movewindow, u
      bind = $mainMod SHIFT, down, movewindow, d

      # TODO: use vdesks after plugin is fixed
      # plugin {
      #   virtual-desktops {
      #     cycleworkspaces = 0
      #     notifyinit = 0
      #     # rememberlayout = monitors
      #   }
      # }
      # bind = $mainMod, page_up, prevdesk
      # bind = $mainMod, page_down, nextdesk
      # bind = $mainMod, mouse_up, prevdesk
      # bind = $mainMod, mouse_down, nextdesk
      # bind = $mainMod SHIFT, page_up, movetoprevdesk
      # bind = $mainMod SHIFT, page_down, movetonextdesk

      bind = $mainMod, page_up, workspace, m-1
      bind = $mainMod, page_down, workspace, m+1
      bind = $mainMod, mouse_up, workspace, m-1
      bind = $mainMod, mouse_down, workspace, m+1
      bind = $mainMod SHIFT, page_up, movetoworkspace, r-1
      bind = $mainMod SHIFT, page_down, movetoworkspace, r+1


      bind = $mainMod, V, exec, clipboard-history

      bind = $mainMod, B, exec, waybar-toggle

      bind = SUPER, SUPER_L, exec, control-panel-toggle

      binde = , XF86MonBrightnessUp, exec, monitor-set-brightness +10%
      binde = , XF86MonBrightnessDown, exec, monitor-set-brightness 10-%
      binde = , XF86AudioRaiseVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+ -l 2.0
      binde = , XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%- -l 2.0
      bind = , XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
      bind = , Print, exec, screenshot

      bind = ALT, space, exec, anyrun

      bind = $mainMod, 1, exec, ghostty
      bind = $mainMod, 2, exec, code
      bind = $mainMod, 3, exec, firefox
      bind = $mainMod, 4, exec, nautilus --new-window
      bind = $mainMod, 5, exec, Enpass
      bind = $mainMod, 6, exec, rio
      bind = $mainMod, 7, exec, spotify
      bind = $mainMod, 8, exec, beeper
      # bind = $mainMod, 9, exec,
      # bind = $mainMod, 0, exec,

      bind = $mainMod SHIFT, Q, exit
      bind = $mainMod SHIFT, R, forcerendererreload
      debug {
        disable_logs = false
      }

      exec-once = waybar
      exec-once = eww daemon
      ${
        if config.opts.system.hardware.gpu.nvidia.monitorDdcciFixEnable then ''
          exec-once = ${pkgs.nu.writeScript "hyprland-monitor-fix-ddcci-nvidia" ''sleep 5sec; monitor-fix-ddcci-nvidia''}
        '' else ""
      }

      # see if a window runs in xwayland
      windowrulev2 = bordercolor rgba(b53600ee), xwayland: 1

      # see if a window is from a vm
      windowrulev2 = bordercolor rgba(0052a5ee), initialTitle: \[vm.*\] - .*

      # app specific rules
      windowrulev2 = float, class:^(.*iwgtk)$
    '';
  };
}
