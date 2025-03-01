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
    rev = "e496e4688603d4ed4b5d0f24f3de9f71068d9fbd";
    hash = "sha256-VHLgD7zdVoL3vdxPbZ0366tA4DcmoLBiV3/9aatqx84=";
  };

  cargoHash = "sha256-37KDDjcIl0MN91IFJ8TRS4VPvAemdMFuQb+q5Fyxeno=";
}
