{ pkgs, lib, config, ... }:

let
  cfg = config.opts.system.login;
in
{
  options = {
    opts.system.login.greeter = lib.mkOption {
      type = lib.types.enum [ "tui" "gui" "tty" ];
      default = "tui";
    };
  };

  config = lib.mkMerge [
    (lib.mkIf (cfg.greeter == "tui") {
      services.greetd = {
        enable = true;
        settings.default_session = {
          command = let
            terminalConfigFile = (pkgs.formats.toml { }).generate "greeter-terminal-config.toml" {
              cursor = "⠀";
              blinking-cursor = false;
              padding-x = 0;
              navigation.mode = "CollapsedTab";
              colors = {
                background = "#1c1c1c";
                foreground = "#aaaaaa";
                cursor = "#aaaaaa";
                selection-background = "#888888";
                selection-foreground = "#1c1c1c";

                black = "#464646";
                white = "#727272";

                dim-black = "#272727";
              };
              fonts = {
                size = 44;
              };
              window.decorations = "Disabled";
            };
            nushellConfigFile = pkgs.writeText "greeter-nushell-config.nu" ''
              (
                ${pkgs.greetd.tuigreet}/bin/tuigreet
                  --time --time-format "%Y-%m-%d %H:%M:%S"
                  --remember --remember-user-session
                  --asterisks --asterisks-char "•"
                  --container-padding 1
                  --width 50
                  --theme "border=darkgray;text=gray;prompt=gray;action=darkgray;button=darkgray;input=gray"
              )
              # try {
              #   ${pkgs.rusty-rain}/bin/rusty-rain -C 74,74,74 -H 110,110,110
              # }
              exit
            '';
          in
          (pkgs.nu.writeScript "greetd-terminal-rio" ''
            mkdir /tmp/greeter-home
            cd /tmp/greeter-home
            mkdir .config
            mkdir .config/rio
            ln -s ${terminalConfigFile} .config/rio/config.toml
            mkdir .config/nushell
            touch .config/nushell/env.nu
            ln -s ${nushellConfigFile} .config/nushell/config.nu
            ${pkgs.cage-no-cursor}/bin/cage -m last -- ${pkgs.rio}/bin/rio --command nu --login
          '');
          user = "greeter";
        };
      };

      users.users.greeter.home = "/tmp/greeter-home";
    })

    (lib.mkIf (cfg.greeter == "gui") {
      platform.system.persist.folders = [
        {
          directory = "/var/cache/regreet";
          user = "greeter";
          group = "greeter";
          mode = "0755";
        }
      ];

      environment.systemPackages = [
        (pkgs.oreo-cursors-plus.override {
          cursorsConf = ''
            custom = color: #1c1c1c, stroke: #eeeeee, stroke-width: 2, stroke-opacity: 1
            sizes = 22
          '';
        })
      ];

      programs.regreet = {
        enable = true;
        settings = {
          GTK = {
            application_prefer_dark_theme = true;
            cursor_theme_name = lib.mkForce "oreo_custom_cursors";
          };
          appearance.greeting_msg = "TimonOS";
        };
        cageArgs = [
          "-m"
          "last"
        ];
      };
    })

    (lib.mkIf (cfg.greeter == "tty") {
      services.greetd = {
        enable = true;
        vt = 7;
        settings.default_session = {
          command = "${pkgs.greetd.tuigreet}/bin/tuigreet -g '' --time --remember --remember-user-session --asterisks";
          user = "greeter";
        };
      };
    })

    (lib.mkIf (cfg.greeter == "tui" || cfg.greeter == "tty") {
      platform.system.persist.folders = [
        {
          directory = "/var/cache/tuigreet";
          user = "greeter";
          group = "greeter";
          mode = "0755";
        }
      ];
    })
  ];
}
