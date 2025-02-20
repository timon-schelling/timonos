{
  fetchFromGitHub,
  rustPlatform,
}:

rustPlatform.buildRustPackage rec {
  pname = "containd";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "timon-schelling";
    repo = pname;
    rev = "08d6c09e667a8077af25222579a4a7e8fb20f1ba";
    hash = "sha256-b5RjQIvmKb/ISpDsyVZnjKw0txdh560OgSZqNi5LrUc=";
  };

  cargoHash = "sha256-Je2xL5EZep7uByoEWTwk5NqHf6XTq8UYmPC2zIKobd8=";
}
