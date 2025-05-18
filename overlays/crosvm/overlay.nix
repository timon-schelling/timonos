inputs: self: super: {
  crosvm = super.crosvm.overrideAttrs (oldAttrs: {
    patches = [
      ./fix-incorrect-type-on-write-pipes.patch
    ] ++ oldAttrs.patches;
  });
}
