{
  lib,
  rustPlatform,
  fetchFromGitHub,
}:

rustPlatform.buildRustPackage rec {
  pname = "rusty-rain";
  version = "unstable-2024-05-11";

  src = fetchFromGitHub {
    owner = "cowboy8625";
    repo = "rusty-rain";
    rev = "c711869d71737ccaccc4510a109c65bc99f2a3f4";
    hash = "sha256-17qDMDe2c5EQg9f7Qy4ADLmRcQVj20hrZsTm68alJEU=";
  };

  cargoLock = {
    lockFile = ./Cargo.lock;
  };

  postPatch = ''
    ln -s ${./Cargo.lock} Cargo.lock
  '';

  meta = {
    description = "Cross platform matrix rain made with Rust";
    homepage = "https://github.com/cowboy8625/rusty-rain";
    changelog = "https://github.com/cowboy8625/rusty-rain/blob/${src.rev}/CHANGELOG.md";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ ravenz46 ];
    mainProgram = "rusty-rain";
  };
}
