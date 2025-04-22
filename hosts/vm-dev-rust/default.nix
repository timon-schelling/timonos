{ lib, pkgs, config, ... }:

{
  imports = [
    ../vm-base
    ../vm-base-workspace
    ../vm-base-lang-rust
  ];

  config = {
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
    ];
  };
}
