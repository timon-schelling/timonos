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
  webkitgtk_4_1,
  fetchNpmDeps,
  wasm-pack,
  llvm,
  binaryen,
  lld,
  libsoup_3,
  vulkan-loader,
  mesa,
  libraw,
  at-spi2-atk,
  atkmm,
  cairo,
  gdk-pixbuf,
  gtk3,
  harfbuzz,
  librsvg,
  pango,
  cargo-about,
}:

rustPlatform.buildRustPackage rec {
  pname = "graphite";
  version = "unstable-2025-05-23";

  src = fetchFromGitHub {
    owner = "GraphiteEditor";
    repo = "graphite";
    rev = "54b4ef145c077c81fba062228e4e79b69bbb9266";
    hash = "sha256-P/7yVjYA8F96K0uCrDzo89sZtYo3/jnJ1taP0bpHgFw=";
  };

  buildAndTestSubdir = "frontend";
  useFetchCargoVendor = true;
  cargoHash = "sha256-RaOTFW+ky9CcLCnr2vLrED41WnWt8a3WMscjdYU/GHM=";

  buildInputs = [
    openssl
    vulkan-loader
    mesa
    libraw

    # Tauri dependencies: keep in sync with https://v2.tauri.app/start/prerequisites/
    at-spi2-atk
    atkmm
    cairo
    gdk-pixbuf
    glib
    gtk3
    harfbuzz
    librsvg
    libsoup_3
    pango
    webkitgtk_4_1
    glib-networking
    openssl
  ];

  npmDepsHash = "sha256-ml+NrXwNP5uUdudyLYk0nsPbJ4Dfkt+uP8yp4NGQUq4=";
  npmDeps = fetchNpmDeps {
    name = "${pname}-npm-deps-${version}";
    src = "${src}/frontend";
    hash = npmDepsHash;
  };
  npmRoot = "frontend";
  npmConfigScript = "setup";
  npmBuildScript = "build";

  installPhase = ''
    cd frontend
    cargo tauri build --no-bundle
    cd ..
    mkdir -p $out/bin
    mv target/release/Graphite $out/bin/graphite
  '';

  nativeBuildInputs = [
    npmHooks.npmConfigHook
    npmHooks.npmBuildHook
    lld
    llvm
    binaryen
    wasm-pack
    cargo-tauri.hook
    cargo-about
    nodejs
    pkg-config
    wrapGAppsHook
    wasm-bindgen-cli
    dbus
  ];

  dontTauriInstall = true;

  doCheck = false;
}