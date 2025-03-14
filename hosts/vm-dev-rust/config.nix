{ lib, pkgs, config, ... }:

{
  imports = [
    ../vm-base
    ../vm-base-workspace
  ];

  config = {
    environment.systemPackages = [
      pkgs.gcc
      (
        let
          rustConfig = {
            extensions = [
              "rust-src"
              "rust-analyzer"
            ];
            targets = [
              "x86_64-unknown-linux-gnu"
            ];
          };
        in
        pkgs.rust-bin.stable.latest.default.override rustConfig
      )
    ];

    nixpkgs.overlays = [
      (self: super:
        let
          overlay = super.fetchFromGitHub {
            repo = "rust-overlay";
            owner = "oxalica";
            rev = "6e6ae2acf4221380140c22d65b6c41f4726f5932";
            sha256 = "YIrVxD2SaUyaEdMry2nAd2qG1E0V38QIV6t6rpguFwk=";
          };
        in
        {
          inherit (import overlay self super) rust-bin;
        }
      )
    ];

    home-manager.users.timon.programs.vscode.extensions = with pkgs.vscode-extensions; [
      rust-lang.rust-analyzer
      tamasfe.even-better-toml
      fill-labs.dependi
    ];
  };
}
