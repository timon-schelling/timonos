{ lib, pkgs, inputs, ... }:

{
  imports = [
    inputs.contain.nixosModules.default
  ];

  contain = {
    enable = true;
    optimizations = true;
    config = {
      cpu = {
        cores = lib.mkDefault 16;
      };
      memory = {
        size = lib.mkDefault 16384;
      };
    };
  };

  opts = {
    system = {
      filesystem.type = "none";
      adminAllowNoPassword = true;
      login.auto = {
        enable = true;
        user = "user";
      };
      desktops.guest.enable = true;
    };
    users = {
      user = {
        admin = true;
        home = {
          desktops.guest.default.enable = true;
          apps = {
            terminal = {
              rio.enable = true;
              ghostty.enable = true;
            };
            editor = {
              vscode.enable = true;
              lapce.enable = true;
            };
            browser = {
              firefox.enable = true;
              chromium.enable = true;
              tor-browser.enable = true;
            };
            filemanager = {
              nautilus.enable = true;
            };
            utils = {
              btop.enable = true;
            };
            passwordmanager = {
              enpass.enable = true;
            };
          };
        };
      };
    };
  };

  boot.kernel.sysctl."net.ipv4.ip_unprivileged_port_start" = lib.mkDefault 64;

  environment.sessionVariables = {
    GDK_BACKEND = "wayland";
    SDL_VIDEODRIVER = "wayland";
    CLUTTER_BACKEND = "wayland";
  };

  environment.systemPackages = [
    (pkgs.nu.writeScriptBin "ip" ''
      def --wrapped main [...args] {
          if ($args | length) > 0 {
              ${pkgs.iproute2}/bin/ip ...$args
          } else {
              ${pkgs.iproute2}/bin/ip --json addr show dev main | from json | get addr_info.0 | filter { $in.family == "inet6" } | get local.0 | echo $"[($in)]" | wl-copy
          }
      }
    '')
  ];

  home-manager.users.user.programs.nushell.extraConfig = lib.mkAfter ''
    alias stop = poweroff
    alias s = stop

    def --wrapped daemon [...args] {
      job spawn { run-external ...$args }
    }
    alias d = daemon

    alias j = daemon ghostty --working-directory=$"\(pwd)"\""
    alias n = daemon rio --working-dir $"\(pwd)"\""
    alias h = daemon code .
    alias k = daemon firefox
    alias l = daemon nautilus .
  '';

  home-manager.users.user.programs.starship.settings.format = lib.mkForce ''
    vm $username $directory ($git_branch$git_status$git_state)
    $character
  '';

  home-manager.users.user.programs.vscode.profiles.default.userSettings.security.workspace.trust.enabled = false;
}
