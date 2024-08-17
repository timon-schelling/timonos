{ plugins, pkgs }:

let
  fetchPluginTarball = { author, name, version, hash }:  pkgs.stdenvNoCC.mkDerivation (
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
      builder = builtins.toFile "download-lapce-plugin.sh" ''
        source "$stdenv/setup"
        url="$(curl ${url})"
        curl -L "$url" -o "$out"
      '';
    }
  );
  fetchPlugin = { author, name, version, hash } @ args: pkgs.stdenvNoCC.mkDerivation {
    name = "lapce-plugin-${author}-${name}-${version}";
    src = fetchPluginTarball args;
    unpackPhase = "true";
    nativeBuildInputs = [ pkgs.zstd ];
    installPhase = ''
      mkdir -p $out
      tar -C $out -xvf $src
    '';
  };
  fetchPlugins = plugins: pkgs.linkFarm "lapce-plugins" (builtins.listToAttrs (
    builtins.map (
      { author, name, version, ... } @ plugin:
      {
        name = "${author}-${name}-${version}";
        value = fetchPlugin plugin;
      }
    ) plugins
  ));
in
fetchPlugins plugins
