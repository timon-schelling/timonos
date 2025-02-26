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
    rev = "44fa657b48c8aeb4472095d6d5d16a13cce34038";
    hash = "sha256-lKglyaRNqhC71wfhZje4ARP6dPvmSjIKYeoWYcwsK1Y=";
  };

  cargoHash = "sha256-37KDDjcIl0MN91IFJ8TRS4VPvAemdMFuQb+q5Fyxeno=";
}
