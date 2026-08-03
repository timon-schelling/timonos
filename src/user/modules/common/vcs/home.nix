{ config, lib, ... }:

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
      settings.user = {
        name = cfg.name;
        email = cfg.email;
      };
    };
    programs.delta = {
      enable = true;
      options = {
        navigate = true;
        syntax-theme = "Monokai Extended";
      };
      enableGitIntegration = true;
      enableJujutsuIntegration = true;
    };
  };
}
