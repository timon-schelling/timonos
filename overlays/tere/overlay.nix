inputs: self: super: {
  tere = super.tere.overrideAttrs {
    patches = [ ./remove-first-run-prompt.patch ];
    doCheck = false;
    doInstallCheck = false;
  };
}
