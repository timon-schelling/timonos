inputs: self: super: {
  rio = super.callPackage ./package.nix { withX11 = false; };
}
