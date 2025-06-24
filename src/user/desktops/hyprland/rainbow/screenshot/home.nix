{ pkgs, lib, ...}:

{
  home.packages = [
    (pkgs.nu.writeScriptBin "screenshot" ''
      def --wrapped main [...args] {
        let screenshot_dir = $"($env.HOME)/tmp/screenshots"
        mkdir $screenshot_dir
        let file = $"($screenshot_dir)/(date now | format date "%Y-%m-%d_%H-%M-%S").png"
        ${lib.getExe pkgs.grimblast} copysave area $file
      }
    '')
  ];
}
