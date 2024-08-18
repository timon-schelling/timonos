inputs: self: super: with super; {
  lapce =
    let
      rpathLibs = lib.optionals stdenv.isLinux [
        libGL
        libxkbcommon
        xorg.libX11
        xorg.libXcursor
        xorg.libXi
        xorg.libXrandr
        xorg.libXxf86vm
        xorg.libxcb
        wayland
      ];
    in
    rustPlatform.buildRustPackage rec {
      pname = "lapce";

      # needs to start with "v" otherwise lapce will use nightly config and data dirs
      version = "v1.0.0-rc-b46aa99ed1a13ff668f0e814af94e94be9e879f3";

      src = fetchFromGitHub {
        owner = "timon-schelling";
        repo = "lapce";
        rev = "b46aa99ed1a13ff668f0e814af94e94be9e879f3";
        hash = "sha256-YvfjTuoK04MeApBR2YBdMh9uGMo03Un4RU5T8eqVYUc=";
      };

      cargoLock = {
        lockFile = ./Cargo.lock;
        outputHashes = {
          "floem-0.1.1" = "sha256-km+WcrOvg2Cd3OQXaHAyF8cfdFlPt5kmgU5lElPguh8=";
          "human-sort-0.2.2" = "sha256-tebgIJGXOY7pwWRukboKAzXY47l4Cn//0xMKQTaGu8w=";
          "lsp-types-0.95.1" = "sha256-+tWqDBM5x/gvQOG7V3m2tFBZB7smgnnZHikf9ja2FfE=";
          "psp-types-0.1.0" = "sha256-/oFt/AXxCqBp21hTSYrokWsbFYTIDCrHMUBuA2Nj5UU=";
          "regalloc2-0.9.3" = "sha256-tzXFXs47LDoNBL1tSkLCqaiHDP5vZjvh250hz0pbEJs=";
          "structdesc-0.1.0" = "sha256-gMTnRudc3Tp9JRa+Cob5Ke23aqajP8lSun5CnT13+eQ=";
          "tracing-0.2.0" = "sha256-31jmSvspNstOAh6VaWie+aozmGu4RpY9Gx2kbBVD+CI=";
          "tree-sitter-bash-0.19.0" = "sha256-gTsA874qpCI/N5tmBI5eT8KDaM25gXM4VbcCbUU2EeI=";
          "tree-sitter-md-0.1.2" = "sha256-gKbjAcY/x9sIxiG7edolAQp2JWrx78mEGeCpayxFOuE=";
          "wasi-experimental-http-wasmtime-0.10.0" = "sha256-FuF3Ms1bT9bBasbLK+yQ2xggObm/lFDRyOvH21AZnQI=";
        };
      };

      env = {
        # Get openssl-sys to use pkg-config
        OPENSSL_NO_VENDOR = 1;

        # This variable is read by build script, so that Lapce editor knows its version
        RELEASE_TAG_NAME = "${version}";
      };

      postPatch = ''
        substituteInPlace lapce-app/Cargo.toml --replace ", \"updater\"" ""
      '';

      nativeBuildInputs = [
        cmake
        pkg-config
        perl
        python3
        wrapGAppsHook3 # FIX: No GSettings schemas are installed on the system
        gobject-introspection
      ];

      buildInputs = rpathLibs ++ [
        glib
        gtk3
        openssl
      ] ++ lib.optionals stdenv.isLinux [
        fontconfig
      ] ++ lib.optionals stdenv.isDarwin [
        libobjc
        Security
        CoreServices
        ApplicationServices
        Carbon
        AppKit
      ];

      postInstall = if stdenv.isLinux then ''
        install -Dm0644 $src/extra/images/logo.svg $out/share/icons/hicolor/scalable/apps/dev.lapce.lapce.svg
        install -Dm0644 $src/extra/linux/dev.lapce.lapce.desktop $out/share/applications/lapce.desktop

        $STRIP -S $out/bin/lapce

        patchelf --add-rpath "${lib.makeLibraryPath rpathLibs}" $out/bin/lapce
      '' else ''
        mkdir $out/Applications
        cp -r extra/macos/Lapce.app $out/Applications
        ln -s $out/bin $out/Applications/Lapce.app/Contents/MacOS
      '';

      dontPatchELF = true;

      doCheck = false;

      passthru.updateScript = nix-update-script { };

      meta = with lib; {
        description = "Lightning-fast and Powerful Code Editor written in Rust";
        homepage = "https://github.com/lapce/lapce";
        changelog = "https://github.com/lapce/lapce/releases/tag/v${version}";
        license = with licenses; [ asl20 ];
        maintainers = with maintainers; [ elliot ];
        mainProgram = "lapce";
        # Undefined symbols for architecture x86_64: "_NSPasteboardTypeFileURL"
        broken = stdenv.isDarwin && stdenv.isx86_64;
      };
    };
}
