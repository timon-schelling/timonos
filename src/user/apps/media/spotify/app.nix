{ pkgs, ... }:

{
  platform.user.persist.folders = [
    ".config/spotify"
    ".cache/spotify"
  ];

  home.packages = [
    (pkgs.runCommand "spotify-wayland" { buildInputs = [ pkgs.makeWrapper ]; } ''
      makeWrapper ${pkgs.spotify}/bin/spotify $out/bin/spotify --set NIXOS_OZONE_WL 1
      mkdir -p "$out/share/applications/"
      cp "${pkgs.spotify}/share/applications/spotify.desktop" "$out/share/applications/"
    '')
  ];
}
