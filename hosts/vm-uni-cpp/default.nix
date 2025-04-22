{ lib, pkgs, config, ... }:

{
  imports = [
    ../vm-base
    ../vm-base-workspace
    ../vm-base-persist
  ];

  config = {
    environment.systemPackages = [
      pkgs.gcc
      pkgs.lldb

      pkgs.qt6.qtwayland
      pkgs.qt6.qt5compat

      pkgs.qtcreator

      pkgs.doxygen_gui

      pkgs.gnumake
      pkgs.cmake

      pkgs.eclipses.eclipse-cpp
    ];
    environment.extraOutputsToInstall = [ "dev" ];
    environment.sessionVariables.CPP_DEPS = "${pkgs.qt6.full}/include";
  };
}
