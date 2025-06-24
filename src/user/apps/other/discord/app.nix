{ pkgs, lib, ... }:

{
  platform.user.persist.folders = [
    ".config/discord"
  ];

  home.packages = [
    (pkgs.runCommand "discord-custom"
      {
        buildInputs = [ pkgs.makeWrapper ];
      }
      ''
        makeWrapper ${lib.getExe pkgs.discord} $out/bin/discord --add-flags "--enable-features=UseOzonePlatform --ozone-platform=wayland"
        cp -r "${pkgs.discord}/share" "$out/"
      ''
    )
  ];
}
