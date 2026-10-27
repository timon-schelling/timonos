inputs: self: super: {
  lix = super.lix.overrideAttrs (old: {
    patches = (old.patches or [ ]) ++ [ ./jj.patch ];
  });
}
