{ lib, pkgs, config, ... }:

{
  config = {
    vm.config = {
      filesystem.shares = [
        {
          tag = "workspace-rw";
          source = ".";
          write = true;
        }
      ];
    };

    fileSystems = {
      "/home/timon/workspace" = {
        device = "workspace-rw";
        fsType = "virtiofs";
        mountPoint = "/home/timon/workspace";
        options = [
          "defaults"
          "x-systemd.requires=systemd-modules-load.service"
        ];
      };
    };

    home-manager.users.timon.programs.nushell.extraConfig = lib.mkAfter ''
      if ((pwd) == $env.HOME) and not ("SUDO_COMMAND" in $env) {
          e ~/workspace
      }
    '';
  };
}
