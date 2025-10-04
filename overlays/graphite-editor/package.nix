{
  graphite-editor-with-placeholder-icons,
  stdenv,
}:

let
  graphite = graphite-editor-with-placeholder-icons;
  icons = graphite.resources.overrideAttrs (_: {
    npmBuildScript = "build-desktop-icons";
  });
  resources = stdenv.mkDerivation {
    pname = "graphite-editor-resources";
    inherit (graphite) version;
    phases = [ "installPhase" ];
    installPhase = ''
      mkdir -p $out
      cp -r ${graphite.resources}/* $out
      chmod -R u+w $out
      cp -rf ${icons}/* $out
    '';
  };
in graphite.overrideAttrs (_: {
  pname = "graphite-editor";
  inherit resources;
})
