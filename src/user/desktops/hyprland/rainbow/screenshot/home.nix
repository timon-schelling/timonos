{ pkgs, ...}:

{
  home.packages = [
    (pkgs.nu.writeScriptBin "screenshot" ''
      def --wrapped main [...args] {
        let screenshot_dir = $"($env.HOME)/tmp/screenshots"
        mkdir $screenshot_dir
        let file = $"($env.HOME)/tmp/screenshots/(date now | format date "%Y-%m-%d_%H-%M-%S").png"
        nix run "nixpkgs#grimblast" -- copysave area $file
      }
    '')
  ];
}
