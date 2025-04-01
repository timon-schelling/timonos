{
  fetchFromGitHub,
  rustPlatform,
}:

rustPlatform.buildRustPackage {
  pname = "contain";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "timon-schelling";
    repo = "contain";
    rev = "a7714a0889aafd98aefcd2468ed92557792722af";
    hash = "sha256-1Ql/MeekhRonq5lD/pBX4Ge8ROi9HKN7Iid9+ijhxbI=";
  };

  useFetchCargoVendor = true;
  cargoHash = "sha256-yXVA5f6v2EOL15RIZlGnQgtTmLUSs6p4OARUlYXaZtE=";
}
