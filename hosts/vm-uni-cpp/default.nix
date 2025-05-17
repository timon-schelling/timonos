{ lib, pkgs, config, ... }:

{
  imports = [
    ../vm-base
    ../vm-base-workspace
    ../vm-base-persist
  ];

  config =
  let
    buildInputs = with pkgs; [
      kdePackages.qtwayland
      kdePackages.qt5compat
      kdePackages.qtbase
    ];
  in
  {
    environment.systemPackages = [
      pkgs.gcc
      pkgs.lldb
      pkgs.gdb

      pkgs.qtcreator

      pkgs.doxygen_gui

      pkgs.gnumake
      pkgs.cmake
      pkgs.kdePackages.full

      pkgs.eclipses.eclipse-cpp
      pkgs.gsettings-desktop-schemas
    ] ++ buildInputs;
    home-manager.users.user.programs.nushell.extraConfig = lib.mkAfter ''
      def --env load_cpp_deps [] {
        $env.CPP_DEPS = $"(ls ${pkgs.kdePackages.full}/include/*/*.h | get name | str join ":")"
      }
    '';
    environment.sessionVariables = {
      C_INCLUDE_PATH = lib.makeIncludePath buildInputs;
      CXX_INCLUDE_PATH = lib.makeIncludePath buildInputs;
    };
    programs.nix-ld = {
      enable = true;
      libraries = [
        pkgs.kdePackages.full
      ];
    };
  };
}
