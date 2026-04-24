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
      rustGpuToolchainPkg = pkgs.rust-bin.nightly."2026-04-11".default.override {
        extensions = [ "rust-src" "rust-analyzer" "clippy" "cargo" "rustc-dev" "llvm-tools" ];
      };
      rustGpuToolchainRustPlatform = pkgs.makeRustPlatform {
        cargo = rustGpuToolchainPkg;
        rustc = rustGpuToolchainPkg;
      };
      rustGpuCodegen = rustGpuToolchainRustPlatform.buildRustPackage (finalAttrs: {
        pname = "rustc_codegen_spirv";
        version = "0.10.0-alpha.1";
        src = pkgs.fetchCrate {
          inherit (finalAttrs) pname version;
          sha256 = "sha256-zJEpExkPgYzwo7fR4ge4GxJNj7H5yo4bJ4eTOw36+7c=";
        };
        cargoHash = "sha256-J1rtbfGqrL2NJ7Bu2pYfDwCdUmnECB/kzxrpYluA0kY=";
        cargoBuildFlags = [
          "-p"
          "rustc_codegen_spirv"
          "--features=use-compiled-tools"
          "--no-default-features"
        ];
        doCheck = false;
      });
      rustGpuCargo = pkgs.writeShellScriptBin "cargo" ''
        #!${pkgs.lib.getExe pkgs.bash}

        filtered_args=()
        for arg in "$@"; do
          case "$arg" in
            +nightly|+nightly-*) ;;
            *) filtered_args+=("$arg") ;;
          esac
        done

        exec ${rustGpuToolchainPkg}/bin/cargo ${"\${filtered_args[@]}"}
      '';
      rustGpuPathOverride = "${rustGpuCargo}/bin:${rustGpuToolchainPkg}/bin";

      cefPath = pkgs.callPackage ./cef/package.nix { inherit pkgs; };

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
        libxcb
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
        nodejs
        binaryen
        wasm-bindgen-cli_0_2_100
        wasm-pack
        pkg-config
        cargo-about
        cargo-deny

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

        flatpak-builder
      ];
    in
    {
      environment.systemPackages = buildInputs ++ buildTools ++ devTools;
      environment.sessionVariables = {
        LD_LIBRARY_PATH = lib.mkForce ("${pkgs.lib.makeLibraryPath buildInputs}:${cefPath}");
        PKG_CONFIG_PATH = pkgs.lib.makeSearchPath "lib/pkgconfig" buildInputs;
        CEF_PATH = cefPath;
        XDG_DATA_DIRS = lib.mkForce "${pkgs.gtk3}/share/gsettings-schemas/${pkgs.gtk3.name}:$XDG_DATA_DIRS";

        # For rust-gpu
        RUST_GPU_PATH_OVERRIDE = rustGpuPathOverride;
        RUSTC_CODEGEN_SPIRV_PATH = "${rustGpuCodegen}/lib/librustc_codegen_spirv.so";
      };
      # home-manager.users.user.programs.nushell.extraConfig = lib.mkAfter ''
      #   alias cargo = mold --run cargo
      # '';
      home-manager.users.user.programs.vscode.profiles.default = {
        extensions = [
          pkgs.vscode-extension-wgsl-analyzer
          pkgs.vscode-extensions.svelte.svelte-vscode
          pkgs.vscode-extensions.dbaeumer.vscode-eslint
          pkgs.vscode-extensions.esbenp.prettier-vscode
          pkgs.vscode-extensions.vitaliymaz.vscode-svg-previewer
          pkgs.vscode-extensions.jgclark.vscode-todo-highlight
        ];
        userSettings."rust-analyzer.cargo.targetDir" = true;
      };

      services.desktopManager.plasma6.enable = true;

      services.flatpak.enable = true;
    };
}
