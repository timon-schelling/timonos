{ pkgs, config, lib, ... }:

{
  platform.user.persist = {
    folders = [
      ".local/share/krita"
    ];
    files = [
      ".config/kritarc"
      ".config/kritadisplayrc"
      ".config/kritashortcutsrc"
    ];
  };

  home.packages = [
    (pkgs.runCommand "krita" { buildInputs = [ pkgs.makeWrapper ]; } ''
      makeWrapper ${lib.getExe pkgs.krita} $out/bin/krita --set QT_QPA_PLATFORM wayland
      mkdir -p "$out/share/applications/"
      cp "${pkgs.krita}/share/applications/"*.desktop "$out/share/applications/"
    '')
  ];
}
