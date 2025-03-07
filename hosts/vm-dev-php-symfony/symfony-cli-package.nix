{ stdenv, fetchurl, lib }:

stdenv.mkDerivation rec {
  pname = "symfony-cli";
  version = "4.23.5";

  src = fetchurl {
    url = "https://github.com/symfony/cli/releases/download/v${version}/symfony_linux_amd64";
    sha256 = "43aef5fd5d45f4602697cad016eff504cb68ec6ad1271c7b1e2a089e1eedd05a";
  };

  phases = [ "installPhase" ];

  installPhase = ''
    mkdir -p $out/bin
    cp $src $out/bin/symfony
    chmod +x $out/bin/symfony
  '';

  meta = with lib; {
    description = "Symfony CLI";
    homepage = "https://symfony.com/download";
    license = licenses.unfree;
    platforms = [ "x86_64-linux" ];
  };
}
