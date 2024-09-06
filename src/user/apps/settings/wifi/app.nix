{ pkgs, ... }:

let
  desktopEntry = pkgs.writeText "settings-wifi.desktop" ''
    [Desktop Entry]
    Type=Application
    Name=Wifi Settings
    Comment=Wireless network management utility
    Exec=settings-wifi
    Icon=iwgtk
    Categories=GTK;Settings;HardwareSettings;
    Terminal=false
  '';
in
{
  home.packages = [
    (pkgs.runCommand "settings-wifi" { buildInputs = [ pkgs.makeWrapper ]; } ''
      makeWrapper ${pkgs.iwgtk}/bin/iwgtk $out/bin/settings-wifi
      mkdir -p "$out/share/applications/"
      cp "${desktopEntry}" "$out/share/applications/settings-wifi.desktop"
      cp -r ${pkgs.iwgtk}/share/icons $out/share/
    '')
  ];
}
