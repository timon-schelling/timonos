{ lib, pkgs, config, ... }:

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
      libcef = pkgs.libcef.overrideAttrs (finalAttrs: previousAttrs: {
        version = "139.0.17";
        gitRevision = "6c347eb";
        chromiumVersion = "139.0.7258.31";
        srcHash = "sha256-kRMO8DP4El1qytDsAZBdHvR9AAHXce90nPdyfJailBg=";

        __intentionallyOverridingVersion = true;

        postInstall = ''
          strip $out/lib/*
        '';
      });

      libcefPath = pkgs.runCommand "libcef-path" {} ''
        mkdir -p $out

        ln -s ${libcef}/include $out/include
        find ${libcef}/lib -type f -name "*" -exec ln -s {} $out/ \;
        find ${libcef}/libexec -type f -name "*" -exec ln -s {} $out/ \;
        cp -r ${libcef}/share/cef/* $out/

        echo '${builtins.toJSON {
          type = "minimal";
          name = builtins.baseNameOf libcef.src.url;
          sha1 = "";
        }}' > $out/archive.json
      '';

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
      ];
      buildTools = with pkgs; [
        rustc-wasm
        nodejs
        nodePackages.npm
        binaryen
        wasm-bindgen-cli
        wasm-pack
        pkg-config
        cargo-about
        cargo-deny

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
        LD_LIBRARY_PATH = lib.mkForce ("${pkgs.lib.makeLibraryPath buildInputs}:${libcefPath}");
        PKG_CONFIG_PATH = pkgs.lib.makeSearchPath "lib/pkgconfig" buildInputs;
        CEF_PATH = libcefPath;
        XDG_DATA_DIRS = "${pkgs.gtk3}/share/gsettings-schemas/${pkgs.gtk3.name}:$XDG_DATA_DIRS";
      };
      home-manager.users.user.programs.nushell.extraConfig = lib.mkAfter ''
        alias cargo = mold --run cargo
      '';
      home-manager.users.user.programs.vscode.profiles.default.extensions = [
        pkgs.vscode-extension-wgsl-analyzer
        pkgs.vscode-extensions.svelte.svelte-vscode
        pkgs.vscode-extensions.dbaeumer.vscode-eslint
        pkgs.vscode-extensions.esbenp.prettier-vscode
        pkgs.vscode-extensions.vitaliymaz.vscode-svg-previewer
        pkgs.vscode-extensions.jgclark.vscode-todo-highlight
      ];
    };
}
