{ lib, pkgs, config, ... }:

{
  imports = [
    ../vm-base-workspace
    ../vm-base-lang-rust
    ../vm-base-podman
  ];

  config = {
    environment.systemPackages = [
      (pkgs.rust-bin.nightly.latest.default.override {
        extensions = [
          "rust-src"
          "rust-analyzer"
        ];
        targets = [
          "x86_64-unknown-linux-gnu"
          "wasm32-unknown-unknown"
        ];
      })
      pkgs.cargo-leptos
      pkgs.cargo-generate
      pkgs.dart-sass
      pkgs.binaryen
    ];
  };
}
