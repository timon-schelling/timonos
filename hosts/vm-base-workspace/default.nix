{ lib, pkgs, config, ... }:

{
  config = {
    contain.config = {
      filesystem.shares = [
        {
          tag = "workspace-rw";
          source = ".";
          write = true;
          inode_file_handles = "never";
        }
      ];
    };

    fileSystems = {
      "/home/user/workspace" = {
        device = "workspace-rw";
        fsType = "virtiofs";
        mountPoint = "/home/user/workspace";
        options = [
          "defaults"
          "x-systemd.requires=systemd-modules-load.service"
        ];
      };
    };

    home-manager.users.user.programs.nushell.extraConfig = lib.mkAfter ''
      if ((pwd) == $env.HOME) and not ("SUDO_COMMAND" in $env) {
          e ~/workspace
      }
    '';
  };
}
