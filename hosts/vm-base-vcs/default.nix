{ lib, pkgs, config, ... }:

{
  opts.users.user.home = {
    name = lib.mkDefault "Timon Schelling";
    email = lib.mkDefault "me@timon.zip";
    git.enable = lib.mkDefault true;
    jujutsu.enable = lib.mkDefault true;
  };
}
