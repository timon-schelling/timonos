# TODO: remove when qtcreator from nixpkgs includes gtk3 gsettings-schemas dependency
inputs: self: super: {
  qtcreator = (self.qt6Packages.callPackage ./package.nix {
    inherit (self.linuxPackages) perf;
    llvmPackages = self.llvmPackages_18;
    stdenv = self.llvmPackages_18.stdenv;
  });
}
