{ lib, pkgs, config, ... }:

{
  imports = [
    ../vm-base
    ../vm-base-workspace
    ../vm-base-vcs
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

          runHook postInstall
        '';
      });
      libs = with pkgs; [
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
          custom-cef
          systemd
          udev
          udev.dev
        ];
    in
    {
      environment.systemPackages = [
        (pkgs.rust-bin.stable.latest.default.override {
          extensions = [
            "rust-src"
            "rust-analyzer"
          ];
          targets = [
            "x86_64-unknown-linux-gnu"
          ];
        })
        pkgs.cmake
        pkgs.pkg-config
        pkgs.python3
        pkgs.gdb
      ];

      home-manager.users.user.programs.nushell.extraConfig = lib.mkAfter ''
        $env.LD_LIBRARY_PATH = "${pkgs.lib.makeLibraryPath libs}"
        $env.PKG_CONFIG_PATH = "${pkgs.lib.makeSearchPath "lib/pkgconfig" libs}"
        $env.CEF_PATH = "${custom-cef}"
        $env.CEF_PATH_NO_CHECK = true
        $env.XDG_DATA_DIRS += ":${pkgs.gtk3}/share/gsettings-schemas/${pkgs.gtk3.name}"
      '';
    };
}
