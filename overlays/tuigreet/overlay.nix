inputs: self: super: {
  greetd = super.greetd // {
    tuigreet = super.greetd.tuigreet.override (old: {
      rustPlatform = old.rustPlatform // {
        buildRustPackage = args: old.rustPlatform.buildRustPackage (args // {
          version = super.greetd.tuigreet.version + "-fixed";
          src = self.fetchFromGitHub {
            owner = "timon-schelling";
            repo = "tuigreet";
            rev = "0919d0fb26841f6febc354ad579c01c6f09c3cd9";
            hash = "sha256-N2IHfpK25qKyMRcXo8fqU3BZuxYHFrHgwhWUD2JW8CU=";
          };
          cargoHash = "sha256-heQmJgEc1WjiafWYag5i8D4gHDTH80Nfc4JKLhHuJAk=";
          doCheck = false;
        });
      };
    });
  };
}
