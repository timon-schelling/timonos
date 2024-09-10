inputs: self: super: {
  # TODO: remove this once the https://github.com/mgunyho/tere/pull/104 is merged and packaged in nixpkgs unstable
  tere-unwrapped = super.tere.override {
    rustPlatform = super.rustPlatform // {
      buildRustPackage = args: self.rustPlatform.buildRustPackage (args // {
        version = "576dfab4efce0048d34712e33d181a20e9dca1a7";
        src = super.fetchFromGitHub {
          owner = "timon-schelling";
          repo = "tere";
          rev = "576dfab4efce0048d34712e33d181a20e9dca1a7";
          hash = "sha256-VvL5xqWQhfu8BSKEYZINk6tma0TXy7rQnFWft/fA6vI=";
        };
        cargoHash = "sha256-FrI3nk/ZeIHp9KMHFYIYzm8FiFhQFzdGoGhn445F3H0=";
        doCheck = false;
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
