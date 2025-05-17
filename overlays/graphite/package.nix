{
  rustPlatform,
  openssl,
  cargo-tauri,
  nodejs,
  npmHooks,
  fetchFromGitHub,
  wrapGAppsHook,
  wasm-bindgen-cli,
  pkg-config,
  dbus,
  glib,
  glib-networking,
  webkitgtk_4_0,
  fetchNpmDeps,
  wasm-pack,
  llvm,
  binaryen,
  lld,
  lib,
}:

rustPlatform.buildRustPackage rec {
  pname = "graphite";
  version = "unstable-2025-05-16";

  src = fetchFromGitHub {
    owner = "GraphiteEditor";
    repo = "graphite";
    rev = "54b4ef145c077c81fba062228e4e79b69bbb9266";
    hash = "sha256-P/7yVjYA8F96K0uCrDzo89sZtYo3/jnJ1taP0bpHgFw=";
  };

  useFetchCargoVendor = true;
  cargoHash = "sha256-RaOTFW+ky9CcLCnr2vLrED41WnWt8a3WMscjdYU/GHM=";

  npmDepsHash = "sha256-un5hxeVyIri+1rw9Lcy2Sg9V1JHLiceFjBY8Fp/Gy5o=";
  npmDeps = fetchNpmDeps {
    name = "${pname}-npm-deps-${version}";
    inherit src;
    hash = npmDepsHash;
    # forceEmptyCache = true;
  };

  buildInputs = [
    openssl
  ];

  npmInstallScript = "setup";

  npmBuildScript = "build";

  nativeBuildInputs = [
    npmHooks.npmConfigHook
    npmHooks.npmInstallHook
    npmHooks.npmBuildHook
    lld
    llvm
    binaryen
    wasm-pack
    cargo-tauri.hook
    nodejs
    pkg-config
    wrapGAppsHook
    wasm-bindgen-cli
    dbus
    glib
    glib-networking
    webkitgtk_4_0
  ];

  doCheck = false;

  buildAndTestSubdir = "frontend/src-tauri";
}