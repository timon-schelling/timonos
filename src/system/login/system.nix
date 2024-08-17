{ pkgs, lib, config, ... }:

let
  cfg = config.opts.system.login;
in
{
  options = {
    opts.system.login.greeter = lib.mkOption {
      type = lib.types.enum [ "tui" "tuigreet" "gui" "regreet" ];
      default = "gui";
    };
  };

  config = lib.mkMerge [
    (lib.mkIf (cfg.greeter == "tui" || cfg.greeter == "tuigreet") {
      platform.system.persist.folders = [
        {
          directory = "/var/cache/tuigreet";
          user = "greeter";
          group = "greeter";
          mode = "0755";
        }
      ];

      services.greetd = {
        enable = true;
        vt = 7;
        settings.default_session = {
          command = "${pkgs.greetd.tuigreet}/bin/tuigreet -g 'TimonOS' --time --remember --remember-user-session --asterisks";
          user = "greeter";
        };
      };
    })

    (lib.mkIf (cfg.greeter == "gui" || cfg.greeter == "regreet") {
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
            cursor_theme_name = "oreo_custom_cursors";
          };
          appearance.greeting_msg = "TimonOS";
        };
        cageArgs = [
          "-m"
          "last"
        ];
      };
    })
  ];
}
