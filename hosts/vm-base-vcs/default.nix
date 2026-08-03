{ lib, pkgs, config, ... }:

{
  opts.users.user.home = {
    name = lib.mkDefault "Timon";
    email = lib.mkDefault "me@timon.zip";
    vcs.enable = lib.mkDefault true;
  };

  home-manager.users.user.programs.jujutsu.settings.ui.editor = "code -w";
}
