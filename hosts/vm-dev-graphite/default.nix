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
      rustExtensions = [ "rust-src" "rust-analyzer" "clippy" "cargo" ];
      rust = pkgs.rust-bin.stable.latest.default.override {
        targets = [ "wasm32-unknown-unknown" ];
        extensions = rustExtensions;
      };

      rustGpuToolchainPkg = pkgs.rust-bin.nightly."2025-06-23".default.override {
        extensions = rustExtensions ++ [ "rustc-dev" "llvm-tools" ];
      };
      rustGpuToolchainRustPlatform = pkgs.makeRustPlatform {
        cargo = rustGpuToolchainPkg;
        rustc = rustGpuToolchainPkg;
      };
      rustGpuCodegen = rustGpuToolchainRustPlatform.buildRustPackage (finalAttrs: {
        pname = "rustc_codegen_spirv";
        version = "0-unstable-2025-08-04";
        src = pkgs.fetchFromGitHub {
          owner = "Rust-GPU";
          repo = "rust-gpu";
          rev = "c12f216121820580731440ee79ebc7403d6ea04f";
          hash = "sha256-rG1cZvOV0vYb1dETOzzbJ0asYdE039UZImobXZfKIno=";
        };
        cargoHash = "sha256-AEigcEc5wiBd3zLqWN/2HSbkfOVFneAqNvg9HsouZf4=";
        cargoBuildFlags = [ "-p" "rustc_codegen_spirv" "--features=use-compiled-tools" "--no-default-features" ];
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

      cefPath = pkgs.cef-binary.overrideAttrs (finalAttrs: {
        postInstall = ''
          rm -r $out/* $out/.* || true
          strip ./Release/*.so*
          mv ./Release/* $out/
          find "./Resources/locales" -maxdepth 1 -type f ! -name 'en-US.pak' -delete
          mv ./Resources/* $out/
          mv ./include $out/

          cat ./CREDITS.html | ${pkgs.xz}/bin/xz -9 -e -c > $out/CREDITS.html.xz

          echo '${
            builtins.toJSON {
              type = "minimal";
              name = builtins.baseNameOf finalAttrs.src.url;
              sha1 = "";
            }
          }' > $out/archive.json
        '';
      });

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
        rust
        nodejs
        nodePackages.npm
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
