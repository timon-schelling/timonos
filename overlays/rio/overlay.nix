inputs: self: super: {
  rio = super.rio.override (old: {
    rustPlatform = old.rustPlatform // {
      buildRustPackage = args: old.rustPlatform.buildRustPackage (args // {
        version = "unstable-2025-04-15";
        src = self.fetchFromGitHub {
          owner = "raphamorim";
          repo = "rio";
          rev = "13883ce92c07e6206c793eb22c4a3415d0aa5256";
          hash = "sha256-SSL/AKvZEfbOcfkdjfVCt6f2gROQ8g4OZAESL5bfZww=";
        };
        cargoHash = "sha256-BU9sTaizo1JgMtJWJ7UE6o+OccQvDXy0c7m82y4pfZ4=";
        doCheck = false;
      });
    };
  });
}
