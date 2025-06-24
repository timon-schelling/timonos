{ pkgs, lib, ... }:

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
        makeWrapper ${lib.getExe pkgs.webcord} $out/bin/webcord --set NIXOS_OZONE_WL 1
        cp -r "${pkgs.webcord}/share" "$out/"
      ''
    )
  ];
}
