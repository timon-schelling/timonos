{ lib, pkgs, config, ... }:

{
  imports = [
    ../vm-base
  ];

  config = {
    environment.systemPackages = [
      pkgs.typst
      pkgs.tinymist
    ];

    home-manager.users.user.programs.vscode.profiles.default.extensions = with pkgs.vscode-extensions; [
      myriad-dreamin.tinymist
    ];

    home-manager.users.user.programs.zed-editor.extensions = [ "typst" ];
  };
}
