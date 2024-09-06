{ pkgs, ... }:

{
  platform.user.persist.folders = [
    ".config/WebCord"
  ];

  home.packages = [
    (pkgs.runCommand "webcord-custom"
      {
        buildInputs = [ pkgs.makeWrapper ];
      }
      ''
        makeWrapper ${pkgs.webcord}/bin/webcord $out/bin/webcord --set NIXOS_OZONE_WL 1
        cp -r "${pkgs.webcord}/share" "$out/"
      ''
    )
  ];
}
