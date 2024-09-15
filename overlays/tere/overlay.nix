inputs: self: super: {
  # TODO: remove this once the https://github.com/NixOS/nixpkgs/pull/342144 is merged in nixpkgs unstable
  tere-unwrapped = super.tere.override {
    rustPlatform = super.rustPlatform // {
      buildRustPackage = args: self.rustPlatform.buildRustPackage (args // {
        version = "v1.6.0";
        src = super.fetchFromGitHub {
          owner = "mgunyho";
          repo = "tere";
          rev = "5adf1176e8c12c073ad244cac7773a7808ed2021";
          hash = "sha256-oY4oeSttM8LLXLirYq/B7Nzajkg4Pw26uig5gZxqU3s=";
        };
        cargoHash = "sha256-1QLVtNGaxdLfnazUeAFUSqadQT+J3NY40zUDa6LCtiY=";
      });
    };
  };
  tere = (self.runCommand "tere-wrapped"
    {
      buildInputs = [ self.makeWrapper ];
    }
    ''
      makeWrapper ${self.tere-unwrapped}/bin/tere $out/bin/tere --add-flags "--skip-first-run-prompt"
    ''
  );
}
