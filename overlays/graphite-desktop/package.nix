{
  rustPlatform,
  fetchFromGitHub,
  fetchNpmDeps,

  npmHooks,
  lld,
  llvm,
  binaryen,
  wasm-pack,
  cargo-tauri,
  cargo-about,
  nodejs,
  pkg-config,
  wrapGAppsHook,
  wasm-bindgen-cli,

  openssl,
  vulkan-loader,
  mesa,
  libraw,

  glib,
  glib-networking,
  gtk3,
  webkitgtk_4_1,
  atkmm,
  gdk-pixbuf,
  cairo,
  at-spi2-atk,
  harfbuzz,
  librsvg,
  libsoup_3,
  pango,
}:

rustPlatform.buildRustPackage rec {
  pname = "graphite-desktop";
  version = "unstable";

  src = fetchFromGitHub {
    owner = "GraphiteEditor";
    repo = "graphite";
    rev = "2cee9e24cd43b2fadefbcfccf03f91417a665dd2";
    hash = "sha256-LoApRismYYabWx2e1L1VapfmE99OCxW7IbgXJk7+gcw=";
  };

  useFetchCargoVendor = true;
  cargoHash = "sha256-ni2cHhGv5CVIP+mB56bZFWAA1qUjb8G7pd0+9FcujeA=";

  npmDeps = fetchNpmDeps {
    inherit pname version;
    src = "${src}/frontend";
    hash = "sha256-XXD04aIPasjHtdOE/mcQ7TocRlSfzHGLiYNFWOPHVrM=";
  };

  buildAndTestSubdir = "frontend";
  npmRoot = "frontend";
  npmConfigScript = "setup";

  nativeBuildInputs = [
    npmHooks.npmConfigHook
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
  ];

  buildInputs = [
    openssl
    vulkan-loader
    mesa
    libraw

    # Tauri dependencies: keep in sync with https://v2.tauri.app/start/prerequisites/
    glib
    glib-networking
    gtk3
    webkitgtk_4_1
    atkmm
    gdk-pixbuf
    cairo
    at-spi2-atk
    harfbuzz
    librsvg
    libsoup_3
    pango
  ];

  buildPhase = ''
    runHook preBuild

    pushd frontend

    npm run build
    cargo tauri build --no-bundle

    popd

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    mv target/release/Graphite $out/bin/graphite-desktop

    runHook postInstall
  '';

  doCheck = false;
}
