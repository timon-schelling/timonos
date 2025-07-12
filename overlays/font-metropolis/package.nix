{ lib, stdenv, fetchurl, unzip }:

stdenv.mkDerivation {
  pname = "font-metropolis";
  version = "unstable";

  src = fetchurl {
    url = "https://fontsarena.com/wp-content/uploads/2018/11/Metropolis-r11.zip";
    hash = "sha256-qe+wGN8/rl05/NPQVBi841xPiOy/nD61T//32/33lGY=";
  };

  nativeBuildInputs = [ unzip ];

  sourceRoot = "Metropolis-r11/Fonts";

  installPhase = ''
    mkdir -p $out/share/fonts/truetype
    mkdir -p $out/share/fonts/opentype
    mkdir -p $out/share/fonts/woff
    mkdir -p $out/share/fonts/woff2
    find . -type f -name '*.ttf' -exec cp '{}' "$out/share/fonts/truetype/" \;
    find . -type f -name '*.otf' -exec cp '{}' "$out/share/fonts/opentype/" \;
    find . -type f -name '*.woff' -exec cp '{}' "$out/share/fonts/woff/" \;
    find . -type f -name '*.woff2' -exec cp '{}' "$out/share/fonts/woff2/" \;
  '';
}
