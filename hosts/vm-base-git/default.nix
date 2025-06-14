{ lib, pkgs, config, ... }:

{
  opts.users.user.home.git = {
    enable = true;
    name = lib.mkDefault "Timon Schelling";
    email = lib.mkDefault "me@timon.zip";
  };
}
