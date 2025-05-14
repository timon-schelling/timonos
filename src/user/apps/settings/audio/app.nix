{ pkgs, ... }:

let
  audioSettingsDesktopEntry = pkgs.writeText "settings-audio.desktop" ''
    [Desktop Entry]
    Type=Application
    Name=Audio Settings
    Comment=Audio settings management utility
    Exec=settings-audio
    Icon=multimedia-volume-control
    Categories=GTK;Settings;HardwareSettings;
    Terminal=false
  '';
  audioSettingsEffectsDesktopEntry = pkgs.writeText "settings-audio-effects.desktop" ''
    [Desktop Entry]
    Type=Application
    Name=Audio Settings - Effects
    Comment=Audio settings effects management utility
    Exec=settings-audio-effects
    Icon=easyeffects
    Categories=GTK;Settings;HardwareSettings;
    Terminal=false
  '';
  audioSettingsGraphDesktopEntry = pkgs.writeText "settings-audio-graph.desktop" ''
    [Desktop Entry]
    Type=Application
    Name=Audio Settings - Graph
    Comment=Audio graph utility
    Exec=settings-audio-graph
    Icon=io.github.dimtpap.coppwr
    Categories=GTK;Settings;HardwareSettings;
    Terminal=false
  '';
in
{
  platform.user.persist.folders = [
    ".config/easyeffects"
  ];
  home.packages = [
    (pkgs.runCommand "settings-audio" { buildInputs = [ pkgs.makeWrapper ]; } ''
      makeWrapper ${pkgs.pavucontrol}/bin/pavucontrol $out/bin/settings-audio
      mkdir -p "$out/share/applications/"
      cp "${audioSettingsDesktopEntry}" "$out/share/applications/settings-audio.desktop"
    '')
    (pkgs.runCommand "settings-audio-effects" { buildInputs = [ pkgs.makeWrapper ]; } ''
      makeWrapper ${pkgs.easyeffects}/bin/easyeffects $out/bin/settings-audio-effects
      mkdir -p "$out/share/applications/"
      cp "${audioSettingsEffectsDesktopEntry}" "$out/share/applications/settings-audio-effects.desktop"
      cp -r ${pkgs.easyeffects}/share/icons $out/share/
    '')
    (pkgs.runCommand "settings-audio-graph" { buildInputs = [ pkgs.makeWrapper ]; } ''
      makeWrapper ${pkgs.coppwr}/bin/coppwr $out/bin/settings-audio-graph
      mkdir -p "$out/share/applications/"
      cp "${audioSettingsGraphDesktopEntry}" "$out/share/applications/settings-audio-graph.desktop"
      cp -r ${pkgs.coppwr}/share/icons $out/share/
    '')
  ];
}