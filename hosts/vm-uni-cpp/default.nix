{ lib, pkgs, config, ... }:

{
  imports = [
    ../vm-base
    ../vm-base-workspace
    ../vm-base-git
    ../vm-base-persist
  ];

  config = {
    environment.systemPackages = [
      pkgs.gcc
      pkgs.lldb
      pkgs.gdb

      pkgs.qt6.qtwayland
      pkgs.qt6.qt5compat

      pkgs.qtcreator

      pkgs.doxygen_gui

      pkgs.gnumake
      pkgs.cmake

      pkgs.eclipses.eclipse-cpp
    ];
    home-manager.users.user.programs.nushell.extraConfig = lib.mkAfter ''
      source ${pkgs.nu.envFromDrv (pkgs.mkShell {
        buildInputs = [
          pkgs.cmake
          pkgs.qt6.qtbase
          pkgs.qt6.qtwayland
          pkgs.qt6.qt5compat
          pkgs.qtcreator
        ];
      }) { }}
    '';
  };
}
