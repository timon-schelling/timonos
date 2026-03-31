inputs: self: super: {
  rust-analyzer-unwrapped = super.rust-analyzer-unwrapped.overrideAttrs (old: {
    patches = old.patches or [] ++ [
      (self.fetchpatch {
        url = "https://patch-diff.githubusercontent.com/raw/rust-lang/rust-analyzer/pull/21915.patch";
        hash = "sha256-/t4KAgbOAI1fhHKLmp+f6wenozB/cjYxZZSDIFY/zkc=";
      })
    ];
  });
}
