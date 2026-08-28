{ pkgs, lib, config, ... }:

let
  home = config.home.homeDirectory;

  stateDir = "${home}/.local/state/noctalia";
  storageKeyFile = "${stateDir}/storage-key";
  overridesFile = "${stateDir}/settings.toml";
  overridesBackupDir = "${stateDir}/tmp";
  screenshotDir = "${home}/tmp/screenshots";

  prestart = pkgs.nu.writeScript "noctalia-prestart" ''
    mkdir "${stateDir}"
    mkdir "${screenshotDir}"

    let overrides = "${overridesFile}"
    if ($overrides | path exists) {
      mkdir "${overridesBackupDir}"
      let stamp = (date now | format date "%Y-%m-%d_%H-%M-%S")
      mv --force $overrides $"${overridesBackupDir}/settings_($stamp).toml"
    }

    let key_file = "${storageKeyFile}"
    if not ($key_file | path exists) {
      ${pkgs.openssl}/bin/openssl rand -hex 32 | save -f $key_file
      ${pkgs.coreutils}/bin/chmod 600 $key_file
    }
  '';

  settings = {

    shell = {
      font_family = "FiraCode Nerd Font";
      time_format = "{:%Y-%m-%d %H:%M:%S}";
      date_format = "%A, %x";

      polkit_agent = true;

      clipboard_enabled = true;
      clipboard_history_max_entries = 1000;
      clipboard_keep_from_closed_apps = true;
      clipboard_confirm_clear_history = true;

      launch_apps_as_systemd_services = true;

      setup_wizard_enabled = false;
      telemetry_enabled = false;
      external_ip_enabled = false;
      show_location = false;
      screen_time_enabled = false;
      app_icon_colorize = false;

      button_borders = false;
      card_borders = false;
      input_borders = false;
      popup_borders = false;

      animation = {
        enabled = true;
        speed = 1.5;
      };

      panel = {
        control_center_position = "top_right";
        open_near_click_control_center = true;
        open_near_click_session = true;
        clipboard_placement = "attached";
        launcher_placement = "attached";
      };

      shadow.alpha = 0.0;

      launcher = {
        categories = false;
        show_icons = true;
        sort_by_usage = true;
        compact = false;
        app_grid = false;
        show_app_actions = false;
        show_app_origin_indicator = false;
        fetch_exchange_rates = false;
        pinned = [ ];
      };

      screenshot = {
        save_to_file = true;
        directory = screenshotDir;
        filename_pattern = "%Y-%m-%d_%H-%M-%S";
        copy_to_clipboard = true;
        freeze_screen = true;
        confirm_region = false;
        remember_last_region = false;
        show_cursor = false;
        pipe_to_command = false;
      };

      session = {
        show_shortcuts = true;
        actions = [
          { action = "logout"; enabled = true; shortcut = "1"; }
          { action = "reboot"; enabled = true; shortcut = "2"; }
          { action = "shutdown"; enabled = true; shortcut = "3"; }
        ];
      };
      screen_corners.enabled = false;
    };

    storage = {
      key_source = "file";
      key_file = storageKeyFile;
    };

    bar.default = {
      enabled = true;
      position = "top";
      start = [ "workspaces" "spacer_a" "media" ];
      center = [ "clock" ];
      end = [
        "battery"
        "sysmon"
        "network"
        "bluetooth"
        "brightness"
        "output_volume"
        "input_volume"
        "screenshot"
        "notifications"
        "session"
      ];
      auto_hide = true;
      reserve_space = false;
      show_on_workspace_switch = false;
      shadow = false;
      thickness = 32;
      padding = 6;
      margin_ends = 0;
      widget_spacing = 8;
      radius = 0;
      capsule_radius = 8;
      capsule_thickness = 1.0;
      concave_edge_corners = false;
      panel_overlap = 0;
    };

    widget = {
      clock = {
        format = "{:%Y-%m-%d %H:%M:%S}";
        timezone = "Europe/Berlin";
      };
      workspaces = {
        show_all_outputs = false;
        hide_when_empty = false;
        show_labels = false;
        pill_scale = 0.65;
        active_pill_size = 2.0;
      };
      "control-center".glyph = "menu-2";
      battery = {
        capsule_fill = "secondary";
        display_mode = "graphic";
        scale = 0.65;
        show_label = false;
      };
      brightness.show_label = false;
      network.show_label = false;
      output_volume = {
        mute_color = "on_surface";
        show_label = false;
      };
      input_volume = {
        mute_color = "on_surface";
        show_label = false;
      };
      media.hide_when_no_media = true;
      sysmon = {
        visualization = "none";
        show_value = false;
        highlight_color = "on_surface_variant";
      };
      spacer_a = {
        type = "spacer";
        length = 15;
      };
    };

    control_center = {
      sidebar = "none";
      sidebar_section = "none";
      width = 1000;
      show_session_button = true;
      show_shortcut_labels = true;
      hidden_tabs = [ "weather" ];
      shortcuts = [ ];
    };

    system.monitor = {
      enabled = true;
      cpu_poll_seconds = 1.0;
      memory_poll_seconds = 1.0;
      disk_poll_seconds = 10.0;
      gpu_poll_seconds = 1.0;
      network_poll_seconds = 1.0;
    };

    battery.warning_threshold = 15;

    brightness = {
      enable_ddcutil = true;
      sync_all_monitors = true;
    };

    audio = {
      enable_overdrive = true;
      enable_sounds = false;
    };

    notification = {
      enable_daemon = true;
      show_app_name = true;
      show_actions = true;
      position = "top_right";
      layer = "top";
      history_retention_hours = 0;
    };

    osd = {
      position = "top_center";
      kinds = {
        volume = true;
        volume_output = true;
        volume_input = true;
        brightness = true;

        wifi = false;
        bluetooth = false;
        power_profile = false;
        caffeine = false;
        nightlight = false;
        dnd = false;
        lock_keys = false;
        keyboard_layout = false;
        media = false;
        privacy = false;
        keyboard_backlight = false;
      };
    };

    theme = {
      source = "custom";
      custom_palette = "custom";
      mode = "dark";

      templates = {
        enable_builtin_templates = true;
        enable_community_templates = false;
        builtin_ids = [ ];
        community_ids = [ ];
      };
    };

    lockscreen = {
      enabled = false;
      lock_before_suspend = false;
    };

    idle = {
      behavior.lock.enabled = false;
      behavior."screen-off".enabled = false;
      behavior.suspend.enabled = false;
    };

    weather.enabled = false;
    wallpaper.enabled = false;
    backdrop.enabled = false;
    dock.enabled = false;
    hot_corners.enabled = false;
  };
in
{
  home.packages = [
    pkgs.noctalia
    pkgs.glib
    pkgs.adw-gtk3
    pkgs.ddcutil
  ];

  platform.user.persist.folders = [
    ".local/state/noctalia"
  ];

  xdg.configFile."noctalia/config.toml".source =
    (pkgs.formats.toml { }).generate "noctalia-config.toml" settings;

  systemd.user.services.noctalia = {
    Unit = {
      Description = "Noctalia Wayland desktop shell";
      Documentation = [ "https://docs.noctalia.dev/v5/" ];
      PartOf = [ "graphical-session.target" ];
      After = [ "graphical-session.target" ];
    };
    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
    Service = {
      Environment = [
        "PATH=${lib.makeBinPath [
          pkgs.ddcutil
          pkgs.glib
          pkgs.bash
          pkgs.coreutils
        ]}:${config.home.profileDirectory}/bin:/run/current-system/sw/bin"
      ];
      Type = "simple";
      ExecStartPre = "${prestart}";
      ExecStart = lib.getExe pkgs.noctalia;
      Restart = "on-failure";
      RestartSec = 1;
      TimeoutStopSec = 10;
    };
  };
}
