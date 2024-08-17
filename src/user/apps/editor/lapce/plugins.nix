{ plugins, pkgs }:

let
  fetchPluginTarZstd = { author, name, version, hash }:  pkgs.stdenvNoCC.mkDerivation (
    let
      url = "https://plugins.lapce.dev/api/v1/plugins/${author}/${name}/${version}/download";
      file = "lapce-plugin-${author}-${name}-${version}.tar.zstd";
    in
    {
      name = file;
      unpackPhase = "true";
      outputHashAlgo = "sha256";
      outputHashMode = "flat";
      outputHash = hash;
      nativeBuildInputs = [ pkgs.curl pkgs.cacert ];
      builder = builtins.toFile "download-lapce-plugin.sh"
      ''
        source "$stdenv/setup"
        url="$(curl ${url})"
        curl -L "$url" -o "$out"
      '';
    }
  );
  fetchPlugin = { author, name, version, hash } @ args: pkgs.stdenvNoCC.mkDerivation (
    let
      dir = "${author}-${name}-${version}";
    in
    {
      name = "lapce-plugin-${dir}";
      src = fetchPluginTarZstd args;
      unpackPhase = "true";
      nativeBuildInputs = [ pkgs.zstd ];
      installPhase = ''
        mkdir -p $out/${dir}
        tar -C $out/${dir} -xvf $src
      '';
    }
  );
  fetchPlugins = plugins: pkgs.symlinkJoin {
    name = "lapce-plugins";
    paths = builtins.map fetchPlugin plugins;
  };
in
fetchPlugins plugins
