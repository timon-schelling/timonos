{ lib, pkgs, config, ... }:

{
  imports = [
    ../vm-base
  ];

  config = {
    environment.systemPackages = [
      pkgs.typst
    ];

    home-manager.users.user.programs.vscode.profiles.default.extensions = with pkgs.vscode-extensions; [
      myriad-dreamin.tinymist
    ];
  };
}
