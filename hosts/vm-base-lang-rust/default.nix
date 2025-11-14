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
          rev = "a35a6144b976f70827c2fe2f5c89d16d8f9179d8";
          hash = "sha256-vINZAJpXQTZd5cfh06Rcw7hesH7sGSvi+Tn+HUieJn8=";
        };
      in
      {
        inherit (import overlay self super) rust-bin;
      }
    )
  ];

  home-manager.users.user = {
    programs.vscode.profiles.default = {
      extensions = with pkgs.vscode-extensions; [
        rust-lang.rust-analyzer
        vadimcn.vscode-lldb
        tamasfe.even-better-toml

        pkgs.vscode-extension-cargo-appraiser
      ];
      userSettings."rust-analyzer.check.command" = "clippy";
      userSettings."rust-analyzer.check.extraArgs" = ["--target-dir" "/home/user/.clippy" "--no-deps"];
      userSettings."rust-analyzer.check.workspace" = false;
    };
  };
}
