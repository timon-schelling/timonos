{ lib, pkgs, config, ... }:

let
  graphiteSrc = pkgs.fetchFromGitHub {
    owner = "GraphiteEditor";
    repo = "Graphite";
    rev = "10907707c2cf462db52b6414fda98ed23effcf85";
    hash = "sha256-y+ArPV9dtoi3c4J9cwFpDy6665VcLyzKC9GDvTqdUNo=";
  };
  graphiteFlakeSrc = pkgs.stdenv.mkDerivation {
    src = graphiteSrc;
    name = "graphite-flake";
    nativeBuildInputs = [ pkgs.jq ];
    phases = [ "unpackPhase" "buildPhase" "installPhase" ];
    buildPhase = ''
      cp ".nix/flake.nix" flake.nix
      jq 'del(.. | .lastModified?)' ".nix/flake.lock" > flake.lock
    '';
    installPhase = ''
      mkdir -p $out
      cp flake.nix $out/flake.nix
      cp flake.lock $out/flake.lock
    '';
  };

  flakeCompat = pkgs.fetchFromGitHub {
    owner = "edolstra";
    repo = "flake-compat";
    rev = "9100a0f413b0c601e0533d1d94ffd501ce2e7885";
    hash = "sha256-CIVLLkVgvHYbgI2UpXvIIBJ12HWgX+fjA8Xf8PUmqCY=";
  };

  getFlake = src: import flakeCompat { inherit src; };

  bashShell = (getFlake graphiteFlakeSrc).outputs.devShells.${pkgs.system}.default;

  nuEnv = pkgs.nu.envFromDrv bashShell {
    postEnvLoadCommands = ''
      $env.WEBKIT_DISABLE_DMABUF_RENDERER = 1

      alias cargo = mold --run cargo
    '';
  };
in
{
  imports = [
    ../vm-base
    ../vm-base-workspace
    ../vm-base-vcs
    ../vm-base-persist
    ../vm-base-lang-rust
  ];

  config =

    let
      custom-cef = pkgs.cef-binary.overrideAttrs (finalAttrs: previousAttrs: {
        version = "138.0.15";
        gitRevision = "d0f1f64";
        chromiumVersion = "138.0.7204.50";
        srcHash = "sha256-9MeJCV0Q2dnOeQ+C5QWBxD6PVzZh9wnhICGI8ak3SAM=";
        nativeBuildInputs = previousAttrs.nativeBuildInputs ++ [ pkgs.rsync ];
        installPhase = ''
          runHook preInstall

          cd ..
          mkdir -p $out
          cp -r Release/* $out
          cp -r Resources/* $out
          rsync ./* $out --exclude Release --exclude Resources

          strip $out/libcef.so

          runHook postInstall
        '';
      });

      rustc-wasm = pkgs.rust-bin.nightly.latest.default.override {
        targets = [ "wasm32-unknown-unknown" ];
        extensions = [ "rust-src" "rust-analyzer" "clippy" "cargo" ];
      };

      buildInputs = with pkgs; [
        # System libraries
        openssl
        openssl.dev
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

        # cef-rs deps
        wayland
        wayland.dev
        gtk3
        glib
        nspr
        nss
        xorg.libxcb
        libxkbcommon
        libxkbcommon.dev
        libGL
        libdrm
        mesa
        alsa-lib
        at-spi2-atk
        at-spi2-core
        atk
        cairo
        cups
        dbus
        expat
        fontconfig
        freetype
        gdk-pixbuf
        pango
        vulkan-loader
        libgbm
        systemd
        udev
        udev.dev
        custom-cef
      ];
      buildTools = with pkgs; [
        rustc-wasm
        nodejs
        nodePackages.npm
        binaryen
        wasm-bindgen-cli
        wasm-pack
        pkg-config
        git
        gobject-introspection
        cargo-tauri
        cargo-about

        cmake
        python3
        gdb

        # Linker
        mold
      ];
      devTools = with pkgs; [
        cargo-watch
        cargo-nextest
        cargo-expand

        # Profiling tools
        gnuplot
        samply
        cargo-flamegraph
      ];
    in
    {
      environment.systemPackages = buildInputs ++ buildTools ++ devTools;
      environment.sessionVariables = {
        LD_LIBRARY_PATH = lib.mkForce ("${pkgs.lib.makeLibraryPath buildInputs}:${custom-cef}");
        PKG_CONFIG_PATH = pkgs.lib.makeSearchPath "lib/pkgconfig" buildInputs;
        CEF_PATH = custom-cef;
        CEF_PATH_NO_CHECK = 1;
        GIO_MODULE_DIR = "${pkgs.glib-networking}/lib/gio/modules/";
        XDG_DATA_DIRS = "${pkgs.gsettings-desktop-schemas}/share/gsettings-schemas/${pkgs.gsettings-desktop-schemas.name}:${pkgs.gtk3}/share/gsettings-schemas/${pkgs.gtk3.name}:$XDG_DATA_DIRS";
      };
      home-manager.users.user.programs.nushell.extraConfig = lib.mkAfter ''
        alias cargo = mold --run cargo
      '';
    };
}
