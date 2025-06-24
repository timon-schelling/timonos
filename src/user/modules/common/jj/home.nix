{ config, lib, ... }:

let
  cfg = config.opts.user.git;
in
{
  options = {
    opts.user.jujutsu = {
      enable = lib.mkEnableOption "Jujutsu";
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
    programs.jujutsu = {
      enable = true;
      settings.user = {
        name = cfg.name;
        email = cfg.email;
      };
    };
  };
}
