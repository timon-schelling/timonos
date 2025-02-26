inputs: self: super: {
  virtiofsd = (self.callPackage ./package.nix {});
}
