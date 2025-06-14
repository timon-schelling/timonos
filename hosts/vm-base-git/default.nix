{ lib, pkgs, config, ... }:

{
  users.user.home.git = {
    enable = true;
    name = lib.mkDefault "Timon Schelling";
    email = lib.mkDefault "me@timon.zip";
  };
}
