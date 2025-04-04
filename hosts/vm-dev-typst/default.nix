{ lib, pkgs, config, ... }:

{
  imports = [
    ../vm-base
    ../vm-base-workspace
  ];

  config = {
    home-manager.users.timon.programs.vscode.profiles.default.extensions = with pkgs.vscode-extensions; [
      myriad-dreamin.tinymist
    ];
  };
}
