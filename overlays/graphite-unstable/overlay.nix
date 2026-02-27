inputs: self: super:

let
  flake = builtins.getFlake "github:GraphiteEditor/Graphite/9ecbfb71105fe4f765889bc3ce76a7638d305d71?dir=.nix";
in
{
  graphite-unstable = self.runCommand "graphite-unstable" {} ''
    mkdir -p $out
    cp -r ${flake.packages.${super.stdenv.hostPlatform.system}.default}/* $out/
    chmod -R u+w $out
    mv $out/bin/graphite $out/bin/graphite-unstable
    mv $out/share/applications/art.graphite.Graphite.desktop $out/share/applications/art.graphite.GraphiteUnstable.desktop
    sed -i 's/Exec=.*/Exec=graphite-unstable/' $out/share/applications/art.graphite.GraphiteUnstable.desktop
    sed -i 's/Name=.*/Name=Graphite Unstable/' $out/share/applications/art.graphite.GraphiteUnstable.desktop
  '';
}
