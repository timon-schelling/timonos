inputs: self: super: {
  rio = super.rio.override (old: {
    rustPlatform = old.rustPlatform // {
      buildRustPackage = args: old.rustPlatform.buildRustPackage (args // {
        version = "unstable-2025-01-06";
        src = self.fetchFromGitHub {
          owner = "raphamorim";
          repo = "rio";
          rev = "d810426a3239fdeda3296afbc85c816bde04d055";
          hash = "sha256-hpDOyPjZKAdWBEC1kZb58dBjAnSUYrUSc4SSTeKTyow=";
        };
        cargoHash = "sha256-kDZjGDzirLu3gLNmV0FheeaCwH6GltI4URywS36nRjI=";
        doCheck = false;
      });
    };
  });
}
