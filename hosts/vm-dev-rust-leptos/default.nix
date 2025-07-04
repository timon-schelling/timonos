{ lib, pkgs, config, ... }:

{
  imports = [
    ../vm-base
    ../vm-base-workspace
    ../vm-base-vcs
    ../vm-base-lang-rust
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
