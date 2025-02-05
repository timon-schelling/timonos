inputs: self: super: {
  sommelier = super.sommelier.overrideAttrs (old: {

    nativeBuildInputs = [ self.gtest ] ++ old.nativeBuildInputs or [];

    doCheck = false;
    doInstallCheck = false;
  });
}
