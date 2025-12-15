{
  lib,
  stdenv,
  rustPlatform,
  fetchFromGitHub,
  fetchurl,
  fetchzip,
  fetchNpmDeps,
  symlinkJoin,
  makeWrapper,
  rustc,
  cargo,
  npmHooks,
  writableTmpDirAsHomeHook,
  lld,
  binaryen,
  wasm-pack,
  cargo-about,
  nodejs,
  pkg-config,
  wasm-bindgen-cli_0_2_100,
  cef-binary,
  wayland,
  openssl,
  vulkan-loader,
  mesa,
  libraw,
  libGL,
}:

let
  version = "0-unstable-2025-12-15";
  rev = "5a36b5eec8aede92ce9f4114334ebe84c2a57211";

  srcHash = "sha256-7VnU378mDTWI9v+rypfXDAsobphGZf3+bP4tItKEGmY=";
  shaderHash = "sha256-uc6FU0df5Xqp6YXEwODULhgUjSQvjRFGvdk+uFB7II0=";
  cargoHash = "sha256-S8nwyUw+ehcHPSbu6dY2+4IVKSB7Tp0K/+2aeiQKNBA=";
  npmHash = "sha256-D8VCNK+Ca3gxO+5wriBn8FszG8/x8n/zM6/MPo9E2j4=";

  brandingRev = "f8b02e68c92f5bbd27626bdd7a51102303b70a40";
  brandingHash = "sha256-Q/p04xtYjt8nEKEPcWRGjTvP54fAr3cLlEpZn61IGyQ=";

  src = fetchFromGitHub {
    owner = "GraphiteEditor";
    repo = "Graphite";
    inherit rev;
    hash = srcHash;
  };

  shaders = fetchurl {
    url = "https://raw.githubusercontent.com/timon-schelling/graphite-artifacts/refs/heads/main/rev/${rev}/raster_nodes_shaders_entrypoint.wgsl";
    hash = shaderHash;
  };

  branding = fetchzip {
    url = "https://github.com/Keavon/graphite-branded-assets/archive/${brandingRev}.tar.gz";
    hash = brandingHash;
  };

  resources = stdenv.mkDerivation (finalAttrs: {
    pname = "graphite-editor-resources";
    inherit version src;

    cargoDeps = rustPlatform.fetchCargoVendor {
      src = finalAttrs.src;
      sourceRoot = finalAttrs.src.name;
      hash = cargoHash;
    };

    npmDeps = fetchNpmDeps {
      inherit (finalAttrs) pname version;
      src = "${finalAttrs.src}/frontend";
      hash = npmHash;
    };

    npmRoot = "frontend";
    npmConfigScript = "setup";
    makeCacheWritable = true;

    nativeBuildInputs = [
      rustPlatform.cargoSetupHook
      rustc
      cargo
      npmHooks.npmConfigHook
      lld
      writableTmpDirAsHomeHook
      binaryen
      wasm-pack
      nodejs
      pkg-config
      wasm-bindgen-cli_0_2_100
      cargo-about
      makeWrapper
    ];

    prePatch = ''
      mkdir branding
      cp -r ${branding}/* branding
      cp $src/.branding branding/.branding
    '';

    buildPhase = ''
      runHook preBuild
      pushd frontend
      npm run native:build-production
      popd
      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall
      mkdir -p $out
      cp -r frontend/dist/* $out/
      runHook postInstall
    '';
  });

  libraries = [
    openssl
    vulkan-loader
    mesa
    libraw
    wayland
    libGL
  ];
  cef = cef-binary.overrideAttrs {
    postFixup = ''
      strip $out/Release/*.so*
    '';
  };
  cefPath = symlinkJoin {
    name = "cef-path";
    paths = [
      "${cef}/Release"
      "${cef}/Resources"
    ];
    postBuild = ''
      ln -s ${cef}/include $out/include
      echo '${
        builtins.toJSON {
          type = "minimal";
          name = builtins.baseNameOf cef.src.url;
          sha1 = "";
        }
      }' > $out/archive.json
    '';
  };
  libraryPath = "${lib.makeLibraryPath libraries}:${cefPath}";

  native = rustPlatform.buildRustPackage (finalAttrs: {
    pname = "graphite-editor-native-application";
    inherit version src cargoHash;

    nativeBuildInputs = [
      pkg-config
      makeWrapper
    ];

    buildInputs = libraries;

    env.CEF_PATH = cefPath;
    env.RASTER_NODES_SHADER_PATH = shaders;
    cargoBuildFlags = [
      "-p"
      "graphite-desktop"
      "--no-default-features"
      "--features"
      "recommended"
    ];

    postUnpack = ''
      mkdir ./branding
      cp -r ${branding}/* ./branding
    '';

    postInstall = ''
      mkdir -p $out/share/applications
      cp $src/desktop/assets/*.desktop $out/share/applications/

      mkdir -p $out/share/icons/hicolor/scalable/apps
      cp ${branding}/app-icons/graphite.svg $out/share/icons/hicolor/scalable/apps/
    '';

    postFixup = ''
      wrapProgram "$out/bin/graphite" \
        --prefix LD_LIBRARY_PATH : "${libraryPath}" \
        --set CEF_PATH "${cefPath}"
    '';

    # There are currently no tests for the desktop application
    doCheck = false;

    meta.mainProgram = "graphite";
  });

  bin = lib.getExe native;

in
stdenv.mkDerivation (finalAttrs: {
  pname = "graphite-editor";
  inherit version resources;

  nativeBuildInputs = [ makeWrapper ];

  dontUnpack = true;
  dontBuild = true;
  installPhase = ''
    runHook preInstall

    makeWrapper ${bin} $out/bin/graphite \
      --set GRAPHITE_RESOURCES ${finalAttrs.resources}

    mkdir -p $out/share
    cp -r ${native}/share/* $out/share/

    runHook postInstall
  '';

  meta = {
    description = "Node-based, non-destructive, procedural 2D vector & raster editor";
    homepage = "https://github.com/GraphiteEditor/Graphite";

    # All of Graphite's code is licensed under Apache-2.0 license.
    #
    # However, this derivation also bundles the official branding which is owned by the Graphite project.
    # NixOS is permitted to redistribute full Graphite sources and binaries, including the official branding.
    license = lib.licenses.unfreeRedistributable;
    maintainers = with lib.maintainers; [ timon ];
    mainProgram = "graphite";
  };
})
