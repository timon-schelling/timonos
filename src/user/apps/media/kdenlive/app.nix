{ pkgs, config, lib, ... }:

{
  platform.user.persist.folders = [
    ".local/share/kdenlive"
    ".cache/kdenlive"
  ];

  home.packages = [
    (pkgs.runCommand "kdenlive"
      {
        buildInputs = [ pkgs.makeWrapper ];
        version = pkgs.kdePackages.kdenlive.version;
        pname = pkgs.kdePackages.kdenlive.pname;
      }
      ''
        makeWrapper ${lib.getExe pkgs.pkgs.kdePackages.kdenlive} $out/bin/kdenlive \
          --prefix PATH : ${pkgs.python3}/bin \
          --prefix FREI0R_PATH : ${pkgs.frei0r}/lib/frei0r-1
        mkdir -p "$out/share/applications/"
        cp -r "${pkgs.kdePackages.kdenlive}/share" "$out/share"
      ''
    )
  ];
}
