{
  lib,
  rustPlatform,
  fetchgit,
}:

rustPlatform.buildRustPackage {
  pname = "way-secure";
  version = "unstable-2025-03-18";

  src = fetchgit {
    url = "https://git.sr.ht/~whynothugo/way-secure";
    rev = "88f963a9745f3ccee35173415ca8aac2a59681af";
    hash = "sha256-1eSLdxbyVfGFRRUpiQXRkiBxSLbZPtnDHE+4Bn73Psg=";
  };

  cargoHash = "sha256-t4zbCfWVYVuiYMw3kESaXM0eFeSULTczPIlHzSMNhw4=";

  doCheck = false;

  meta = {
    description = "A helper to create Wayland security contexts via security_context_v1.";
    homepage = "https://git.sr.ht/~whynothugo/way-secure";
    mainProgram = "way-secure";
  };
}
