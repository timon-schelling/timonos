{ lib, pkgs, config, ... }:

{
  imports = [
    ../vm-base
    ../vm-base-workspace
    ../vm-base-vcs
    ../vm-base-lang-typst
  ];

  config = {
    environment.systemPackages = with pkgs; [
      (python3.withPackages (p: with p; [
        numpy
        matplotlib
        pyqt6
        torch
        scikit-learn
        gym
      ]))
      kdePackages.qtwayland
    ];

    environment.sessionVariables.MPLBACKEND = "qtagg";

    home-manager.users.user.programs.vscode.profiles.default.extensions = with pkgs.vscode-extensions; [
      ms-python.python
    ];
  };
}
