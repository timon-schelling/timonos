{ ... }:
let
  modulePath = [ "programs" "zen-browser" ];
  mkFirefoxModule = import ./mkFirefoxModule.nix;
in {
  imports = [
    (mkFirefoxModule {
      inherit modulePath;
      name = "Zen Browser";
      wrappedPackageName = "zen-browser";
      visible = true;
      platforms.linux = rec {
        vendorPath = ".zen";
        configPath = "${vendorPath}";
      };
      platforms.darwin = {
        vendorPath = "Library/Application Support/Zen";
        configPath = "Library/Application Support/Zen";
      };
    })
  ];
}
