{ lib, pkgs, config, ... }:

{
  environment.systemPackages = [
    pkgs.gcc
    pkgs.lldb
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

  home-manager.users.user = {
    programs.vscode.profiles.default.extensions = with pkgs.vscode-extensions; [
      rust-lang.rust-analyzer
      vadimcn.vscode-lldb
      tamasfe.even-better-toml

      pkgs.vscode-extension-cargo-appraiser
    ];
  };
}
