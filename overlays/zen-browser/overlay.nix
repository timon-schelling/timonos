inputs: self: super: rec {
  zen-browser-unwrapped = super.callPackage ./package.nix { };
  zen-browser = super.wrapFirefox zen-browser-unwrapped { pname = "zen-browser"; };
}
