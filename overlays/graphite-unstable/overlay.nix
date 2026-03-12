inputs: self: super:

let
  flake = builtins.getFlake "github:GraphiteEditor/Graphite/a3f88b0f966d8c22d89999e29b607f824206f380";
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
