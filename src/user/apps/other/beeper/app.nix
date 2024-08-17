{ pkgs, ... }:

{
  platform.user.persist.folders = [
    ".config/Beeper"
  ];

  home.packages = [
    (pkgs.runCommand "beeper-custom"
      {
        buildInputs = [ pkgs.makeWrapper ];
      }
      ''
        makeWrapper ${pkgs.beeper}/bin/beeper $out/bin/beeper --set NIXOS_OZONE_WL 1 --add-flags "--default-frame"
        cp -r "${pkgs.beeper}/share" "$out/"
      ''
    )
  ];
}
