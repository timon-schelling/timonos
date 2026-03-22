inputs: self: super: {
  rust-analyzer-unwrapped = (self.callPackage ./package.nix {});
}
