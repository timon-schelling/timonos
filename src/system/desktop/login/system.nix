{ pkgs, lib, config, ... }:

let
  cfg = config.opts.system.login;
in
{
  options = {
    opts.system.login = {
      greeter = lib.mkOption {
        type = lib.types.enum [ "tui" "gui" "tty" ];
        default = "tui";
      };
      auto = lib.mkOption {
        type = lib.types.submodule {
          options = {
            enable = lib.mkEnableOption "Enable auto login";
            user = lib.mkOption {
              type = lib.types.str;
            };
            command = lib.mkOption {
              type = lib.types.path;
              default = pkgs.nu.writeScript "greetd-auto-login" ''
                let user = getent passwd $env.USER | complete | get stdout | lines | first
                let start_shell_pos = ($user | str index-of --end ":") + 1
                run-external ( $user | str substring $start_shell_pos.. )
              '';
            };
          };
        };
        default = { };
      };
    };
  };

  config = lib.mkMerge [

    {
      services.greetd.enable = true;
    }

    (lib.mkIf cfg.auto.enable {
      services = {
        greetd.settings.initial_session = {
          user = cfg.auto.user;
          command = "${cfg.auto.command}";
        };
        getty = {
          autologinUser = cfg.auto.user;
        };
      };
    })

    (lib.mkIf (cfg.greeter == "tui") {
      services.greetd = {
        enable = true;
        settings.default_session = {
          command = let
            terminalConfigFile = (pkgs.formats.toml { }).generate "greeter-terminal-config.toml" {
              cursor = {
                shape = "beam";
                blink = false;
              };
              padding-x = 0;
              navigation.mode = "Plain";
              colors = {
                background = "#1c1c1c";
                foreground = "#aaaaaa";
                cursor = "#aaaaaa";
                selection-background = "#888888";
                selection-foreground = "#1c1c1c";
                black = "#464646";
                white = "#aaaaaa";
                dim-black = "#272727";
              };
              fonts = {
                size = 44;
              };
              window.decorations = "Disabled";
            };
            nushellConfigFile = pkgs.writeText "greeter-nushell-config.nu" ''

              # TODO: remove this fix once the issue is resolved
              # dirty fix to tuigreet from crashing
              # could be an issue with tuigreet, nushell or rio
              # probably related to a not properly initialized terminal
              # right after starting the session
              sleep 10ms
              print " "
              sleep 10ms

              (
                ${lib.getExe pkgs.greetd.tuigreet}
                  --time --time-format "%Y-%m-%d %H:%M:%S"
                  --remember --remember-user-session
                  --asterisks --asterisks-char "•"
                  --container-padding 1
                  --width 50
                  --theme "border=darkgray;text=gray;prompt=gray;action=darkgray;button=darkgray;input=gray"
              )
              exit
            '';
          in
          (pkgs.nu.writeScript "greetd-terminal-rio" ''
            mkdir /tmp/greeter-home
            cd /tmp/greeter-home
            mkdir .config
            mkdir .config/rio
            try { ln -s ${terminalConfigFile} .config/rio/config.toml }
            mkdir .config/nushell
            try { touch .config/nushell/env.nu }
            try { ln -s ${nushellConfigFile} .config/nushell/config.nu }
            ${lib.getExe pkgs.cage-no-cursor} -m last -- ${lib.getExe pkgs.rio} --command nu --login
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
        pkgs.oreo-custom-cursors
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
          command = "${lib.getExe pkgs.greetd.tuigreet} -g '' --time --remember --remember-user-session --asterisks";
          user = "greeter";
        };
      };

      # Set kernel console to tty1 to prevent the kernel from overwriting tuigreet output
      boot.kernelParams = [ "console=tty1"];
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
