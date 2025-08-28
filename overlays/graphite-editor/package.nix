{
  lib,
  stdenv,
  rustPlatform,
  fetchFromGitHub,
  fetchNpmDeps,
  makeWrapper,
  npmHooks,
  lld,
  llvm,
  binaryen,
  wasm-pack,
  cargo-about,
  nodejs,
  pkg-config,
  wasm-bindgen-cli_0_2_100,
  libcef,
  wayland,
  openssl,
  vulkan-loader,
  mesa,
  libraw,
  libGL,
}:

let
  cef-path = stdenv.mkDerivation {
    pname = "cef-path";
    version = libcef.version;
    dontUnpack = true;
    installPhase = ''
      mkdir -p "$out"
      find ${libcef}/lib -type f -name "*" -exec cp {} $out/ \;
      find ${libcef}/libexec -type f -name "*" -exec cp {} $out/ \;
      cp -r ${libcef}/share/cef/* $out/

      mkdir -p "$out/include"
      cp -r ${libcef}/include/* "$out/include/"
    '';
    postFixup = ''
      strip $out/*.so*
    '';
  };
in
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "graphite-editor";
  version = "0-unstable-2025-08-23";

  src = fetchFromGitHub {
    owner = "GraphiteEditor";
    repo = "Graphite";
    rev = "6d640d2c5cc8d0b4e6d23798d46e787bbb84012a";
    hash = "sha256-9n6hKBKNTwCohb/tX1MpnB54T9zZTfy4P0zgC2JieW8=";
  };

  cargoHash = "sha256-r8L39GflLsSWsJfPvCrF1FiB/fogr6Km3cYdVAjHwI8=";

  npmDeps = fetchNpmDeps {
    inherit (finalAttrs) pname version;
    src = "${finalAttrs.src}/frontend";
    hash = "sha256-RGcSQgUEtUK1ATKMVUqcuhsYgMJDtYyAoEHBvPVQlCo=";
  };

  buildAndTestSubdir = "desktop";
  npmRoot = "frontend";
  npmConfigScript = "setup";
  makeCacheWritable = true;

  nativeBuildInputs = [
    npmHooks.npmConfigHook
    lld
    llvm
    binaryen
    wasm-pack
    nodejs
    pkg-config
    wasm-bindgen-cli_0_2_100
    cargo-about
    makeWrapper
  ];

  buildInputs = [
    openssl
    vulkan-loader
    mesa
    libraw
    wayland
    libGL
  ];

  postPatch = ''
    substituteInPlace $cargoDepsCopy/cef-dll-sys-*/build.rs \
      --replace-fail 'download_cef::check_archive_json(&env::var("CARGO_PKG_VERSION")?, &cef_path)?;' '''
  '';

  preBuild = ''
    pushd frontend

    npm run build-native

    popd
  '';

  env.CEF_PATH = cef-path;
  cargoBuildFlags = [
    "-p"
    "graphite-desktop"
  ];

  postInstall = ''
    mkdir -p $out/share/applications
    cp $src/desktop/assets/*.desktop $out/share/applications/

    mkdir -p $out/share/icons/hicolor/scalable/apps
    cp $src/desktop/assets/graphite-icon-color.svg $out/share/icons/hicolor/scalable/apps/
  '';

  postFixup = ''
    mv $out/bin/graphite-desktop $out/bin/graphite-editor
    wrapProgram "$out/bin/graphite-editor" \
      --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath finalAttrs.buildInputs}:${cef-path}" \
      --set CEF_PATH "${cef-path}"
  '';

  # There are currently no tests for the desktop application
  doCheck = false;

  meta = {
    description = "2D vector & raster editor that melds traditional layers & tools with a modern node-based, non-destructive, procedural workflow";
    homepage = "https://github.com/GraphiteEditor/Graphite";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ timon ];
    mainProgram = "graphite-editor";
  };
})
