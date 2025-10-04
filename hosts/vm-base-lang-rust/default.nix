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
          rev = "0ad7ab4ca8e83febf147197e65c006dff60623ab";
          hash = "sha256-jmQeEpgX+++MEgrcikcwoSiI7vDZWLP0gci7XiWb9uQ=";
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
