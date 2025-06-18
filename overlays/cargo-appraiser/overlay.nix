inputs: self: super: {
  cargo-appraiser = (self.callPackage ./package.nix {});
}
