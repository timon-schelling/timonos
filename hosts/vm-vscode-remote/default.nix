{ lib, pkgs, config, ... }:

{
  imports = [
    ../vm-base
  ];

  config = {
    home-manager.users.user = {
      programs.vscode.profiles.default.extensions = with pkgs.vscode-extensions; [
        ms-vscode-remote.remote-ssh
        ms-vscode.remote-explorer
      ];
    };
    programs.ssh.systemd-ssh-proxy.enable = false;
  };
}
