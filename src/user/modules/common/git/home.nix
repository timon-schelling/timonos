{ config, lib, ... }:

let
  cfg = config.opts.user.git;
in
{
  options = {
    opts.user.git = {
      enable = lib.mkEnableOption "Git";
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
      userName = cfg.name;
      userEmail = cfg.email;
      extraConfig.init.defaultBranch = "main";
    };
  };
}
