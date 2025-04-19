{ pkgs, lib, config, ... }:

{
  imports = [
    ../vm-base
  ];

  opts.users.user.home.podman.enable = true;
}
