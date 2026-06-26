inputs: self: super:

let
  # flake = builtins.getFlake "github:GraphiteEditor/Graphite/a10092c10ce28a86819e7d39f5dc2bd02725d058";
  graphite-unstable-script = self.nu.writeScriptBin "graphite-unstable" ''
    def main [...args] {
      let cutoff = (date now) - 1.5hr

      let sha = (
        http get "https://api.github.com/repos/GraphiteEditor/Graphite/commits?sha=master&per_page=10"
          --headers {Accept: "application/vnd.github+json"}
        | where { |commit| $commit.commit.author.date | into datetime | $in < $cutoff }
        | first
        | get sha
      )

      let pkg = $"github:GraphiteEditor/Graphite/($sha)"

      ${self.ghostty}/bin/ghostty -e ${self.bash}/bin/sh -c $"${self.nix}/bin/nix --extra-experimental-features 'nix-command flakes' build --no-link '($pkg)'|| { echo 'Build failed, press enter to close'; read _; }"

      ${self.nix}/bin/nix --extra-experimental-features 'nix-command flakes' run $pkg -- ...$args
    }
  '';
in
{
  graphite-unstable = self.runCommand "graphite-unstable" {} ''
    mkdir -p $out
    cp -r ${graphite-unstable-script}/* $out/
    chmod -R u+w $out
    mkdir -p $out/share
    cp ${super.graphite}/share/* $out/share/ -r
    chmod -R u+w $out
    mv $out/share/applications/art.graphite.Graphite.desktop $out/share/applications/art.graphite.GraphiteUnstable.desktop
    sed -i 's/Exec=.*/Exec=graphite-unstable/' $out/share/applications/art.graphite.GraphiteUnstable.desktop
    sed -i 's/Name=.*/Name=Graphite Unstable/' $out/share/applications/art.graphite.GraphiteUnstable.desktop
  '';
}
