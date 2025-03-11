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
    rev = "46715a307f6b7a9812ccfad79515864badb38c99";
    hash = "sha256-dh5GQENcDpPKrpkkMY1hyHM02FBRM7Qna2AYdq/8EXM=";
  };

  cargoHash = "sha256-PtavpnR2CKGFhgAznMHpg8DzC0dkP+HrgMjd99zf9sA=";
}
