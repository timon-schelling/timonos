{ lib, pkgs, config, ... }:

{
  imports = [
    ../vm-base
    ../vm-base-workspace
    ../vm-base-vcs
    ../vm-base-persist
  ];

  config =
    let
      libs = [
        pkgs.qt6.qtbase.dev
        pkgs.qt6.full
        pkgs.qt6.full
        pkgs.qt6.qtbase
        pkgs.qt6.qtwayland
        pkgs.qt6.qt5compat
        pkgs.gcc
        pkgs.qt6.wrapQtAppsHook
      ];
      includePath = "${pkgs.stdenv.cc.cc.lib}/include/:${pkgs.lib.makeIncludePath libs}:$NIX_INCLUDE_PATH";
    in
    {
    environment.systemPackages = [
      pkgs.lldb
      pkgs.gdb
      pkgs.gcc

      pkgs.qtcreator

      pkgs.doxygen_gui

      pkgs.gnumake
      pkgs.cmake

      pkgs.eclipses.eclipse-cpp
    ] ++ libs;
    home-manager.users.user.programs.nushell.extraConfig = lib.mkAfter ''
      source ${pkgs.nu.envFromDrv (pkgs.mkShell {
        buildInputs = [
          pkgs.cmake
          pkgs.qtcreator
        ] ++ libs;
      }) { }}
      $env.INCLUDE_PATH = "${includePath}"
      $env.C_INCLUDE_PATH = "${includePath}"
      $env.CPLUS_INCLUDE_PATH = "${includePath}"
      $env.LD_LIBRARY_PATH = "${pkgs.stdenv.cc.cc.lib}/lib/:${pkgs.lib.makeLibraryPath libs}:$NIX_LD_LIBRARY_PATH"
    '';
  };
}
