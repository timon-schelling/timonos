{ lib, pkgs, config, ... }:

{
  imports = [
    ../vm-base
    ../vm-base-workspace
  ];

  config = {
    environment.systemPackages = [
      pkgs.gcc
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

    home-manager.users.timon = {
      programs.vscode.profiles.default.extensions = with pkgs.vscode-extensions; [
        rust-lang.rust-analyzer
        tamasfe.even-better-toml
      ] ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
        {
          publisher = "washan";
          name = "cargo-appraiser";
          version = "0.0.7";
          sha256 = "sha256-hQxgTNo2WRiTCy4IUGo/r3UdQDjcEJbiJc1+3rCWzXo=";
        }
      ];
      home.sessionVariables."CARGO_APPRAISER_PATH" = "${(pkgs.callPackage ./cargo-appraiser-package.nix {})}/bin/cargo-appraiser";
    };
  };
}
