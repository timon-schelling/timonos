{ lib, pkgs, config, ... }:

{
  environment.systemPackages = [
    pkgs.go
  ];

  home-manager.users.user = {
    programs.vscode.profiles.default.extensions = with pkgs.vscode-extensions; [
      golang.go
    ];
  };
}
