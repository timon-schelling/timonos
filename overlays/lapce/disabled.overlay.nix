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
      version = "v1.0.0-rc-39053ea7817a561222a285427e8b237041f49824";

      src = fetchFromGitHub {
        owner = "timon-schelling";
        repo = "lapce";
        rev = "39053ea7817a561222a285427e8b237041f49824";
        hash = "sha256-+6W7dUsU7g5fvz1F3W9A5X/P6mEkO0OEB92oeuGpn/Y=";
      };

      cargoLock = {
        lockFile = ./Cargo.lock;
        outputHashes = {
          "alacritty_terminal-0.24.1-dev" = "sha256-aVB1CNOLjNh6AtvdbomODNrk00Md8yz8QzldzvDo1LI=";
          "floem-0.1.1" = "sha256-/4Y38VXx7wFVVEzjqZ2D6+jiXCXPfzK44rDiNOR1lAk=";
          "human-sort-0.2.2" = "sha256-tebgIJGXOY7pwWRukboKAzXY47l4Cn//0xMKQTaGu8w=";
          "locale_config-0.3.1-alpha.0" = "sha256-cCEO+dmU05TKkpH6wVK6tiH94b7k2686xyGxlhkcmAM=";
          "lsp-types-0.95.1" = "sha256-+tWqDBM5x/gvQOG7V3m2tFBZB7smgnnZHikf9ja2FfE=";
          "psp-types-0.1.0" = "sha256-/oFt/AXxCqBp21hTSYrokWsbFYTIDCrHMUBuA2Nj5UU=";
          "regalloc2-0.9.3" = "sha256-tzXFXs47LDoNBL1tSkLCqaiHDP5vZjvh250hz0pbEJs=";
          "structdesc-0.1.0" = "sha256-KiR0R2YWZ7BucXIIeziu2FPJnbP7WNSQrxQhcNlpx2Q=";
          "tracing-0.2.0" = "sha256-31jmSvspNstOAh6VaWie+aozmGu4RpY9Gx2kbBVD+CI=";
          "wasi-experimental-http-wasmtime-0.10.0" = "sha256-FuF3Ms1bT9bBasbLK+yQ2xggObm/lFDRyOvH21AZnQI=";
        };
      };
      cargoHash = "";

      env = {
        # Get openssl-sys to use pkg-config
        OPENSSL_NO_VENDOR = 1;

        # This variable is read by build script, so that Lapce editor knows its version
        RELEASE_TAG_NAME = "${version}";

        # see https://github.com/rust-lang/cargo/issues/10679
        RUSTFLAGS = "-Ctarget-feature=-crt-static";
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
