inputs: self: super: {
  rio = super.rio.override (old: {
    rustPlatform = old.rustPlatform // {
      buildRustPackage = args: old.rustPlatform.buildRustPackage (args // {
        version = "unstable-2025-01-06";
        src = self.fetchFromGitHub {
          owner = "raphamorim";
          repo = "rio";
          rev = "8df8d407765333c1067f5ce0460573b79e946da2";
          hash = "sha256-Iz4OcrqOgXqxblLYTrW7a3lftOAMXgcWiW1+ATSkOEY=";
        };
        cargoHash = "sha256-kDZjGDzirLu3gLNmV0FheeaCwH6GltI4URywS36nRjI=";
        doCheck = false;
      });
    };
  });
}
