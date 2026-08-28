{ config, lib, pkgs, ... }:

let
  cfg = config.opts.user.vcs;
in
{
  options = {
    opts.user.vcs = {
      enable = lib.mkEnableOption "VCS";
      name = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = config.opts.user.name;
      };
      email = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = config.opts.user.email;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    programs.git = {
      enable = true;
      settings= {
        user.name = cfg.name;
        user.email = cfg.email;
        init.defaultBranch = "main";
        merge.conflictstyle = "diff3";
      };
      ignores = [
        ".jj/"
        ".tmp/"
        ".Trash-*"
      ];
    };

    programs.jujutsu = {
      enable = true;
      settings = {
        user = {
          name = cfg.name;
          email = cfg.email;
        };
        revset-aliases = {
          "immutable_heads()" = "remote_bookmarks(regex:'^(main|master)$')";
        };
        aliases = {
          setup = [ "util" "exec" "--" "jjf" "setup" ];
          sync = [ "util" "exec" "--" "jjf" "sync" ];
          pub = [ "util" "exec" "--" "jjf" "pub" ];
          unpub = [ "util" "exec" "--" "jjf" "unpub" ];
          arc = [ "util" "exec" "--" "jjf" "arc" ];
          unarc = [ "util" "exec" "--" "jjf" "unarc" ];
          arcs = [ "util" "exec" "--" "jjf" "arcs" ];
        };
      };
    };
    home.packages = [
      (pkgs.nu.writeScriptBin "jjf" (builtins.readFile ./jjf.nu))
    ];

    programs.delta = {
      enable = true;
      options = {
        navigate = true;
        syntax-theme = "Monokai Extended";
      };
      enableGitIntegration = true;
      enableJujutsuIntegration = true;
    };

    services.ssh-agent.enable = true;
    programs.ssh = {
      enable = true;
      matchBlocks."*".addKeysToAgent = "yes";
    };
  };
}
