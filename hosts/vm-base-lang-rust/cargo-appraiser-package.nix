{
  fetchFromGitHub,
  rustPlatform,
  pkg-config,
  openssl,
}:

rustPlatform.buildRustPackage {
  pname = "cargo-appraiser";
  version = "unstable-2025-03-19";

  src = fetchFromGitHub {
    owner = "washanhanzi";
    repo = "cargo-appraiser";
    rev = "ca6f71ad82a87803a35167bd40e5189a1e2fce88";
    hash = "sha256-eFhN7v/GfWJSlC6yQ3dxBMBDs93e1I+LX6lQ5XMe2oA=";
  };

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ openssl ];

  doCheck = false;

  useFetchCargoVendor = true;
  cargoHash = "sha256-q/WhdgsTS6OgzH+e7vapYwfQstSiGzYHyL+YDMmefP4=";
}
