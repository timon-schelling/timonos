# TODO: remove once https://github.com/NixOS/nixpkgs/pull/395624 is merged in nixpkgs-unstable
inputs: self: super: {
  beeper = (super.callPackage ./package.nix { });
}
