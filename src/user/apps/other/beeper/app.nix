{ pkgs, ... }:

{
  platform.user.persist.folders = [
    ".config/BeeperTexts"
  ];

  home.packages = [
    (pkgs.runCommand "beeper-custom"
      {
        buildInputs = [ pkgs.makeWrapper ];
      }
      ''
        makeWrapper ${pkgs.beeper}/bin/beeper $out/bin/beeper --set NIXOS_OZONE_WL 1
        cp -r "${pkgs.beeper}/share" "$out/"
      ''
    )
  ];
}
