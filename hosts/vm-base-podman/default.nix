{ pkgs, lib, config, ... }:

{
  imports = [
    ../vm-base
  ];

  opts.users.timon.home.podman.enable = true;
}
