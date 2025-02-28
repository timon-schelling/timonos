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
    rev = "7c0615bb297eef0dad8b44fcadfc45119478abbd";
    hash = "sha256-YRDaGh2zLUt+CLwCKnFdZrinb7C39O2O6p2nK7j/2Ms=";
  };

  cargoHash = "sha256-37KDDjcIl0MN91IFJ8TRS4VPvAemdMFuQb+q5Fyxeno=";
}
