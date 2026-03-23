inputs: self: super:

let
  flake = builtins.getFlake "github:GraphiteEditor/Graphite/a10092c10ce28a86819e7d39f5dc2bd02725d058";
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
