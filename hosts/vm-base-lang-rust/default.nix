{ lib, pkgs, config, ... }:

{
  environment.systemPackages = [
    pkgs.rustc
    pkgs.cargo
    pkgs.gcc
    pkgs.lldb
    pkgs.lld
    pkgs.rust-analyzer
    pkgs.clippy
  ];

  nixpkgs.overlays = [
    (self: super:
      let
        overlay = super.fetchFromGitHub {
          repo = "rust-overlay";
          owner = "oxalica";
          rev = "403c09094a877e6c4816462d00b1a56ff8198e06";
          hash = "sha256-CZ5FKUSA8FCJf0h9GWdPJXoVVDL9H5yC74GkVc5ubIM=";
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
      userSettings."rust-analyzer.check.workspace" = false;
    };

    programs.zed-editor = {
      extensions = [ "toml" "cargo-appraiser" ];
      userSettings.lsp."rust-analyzer".initialization_options = {
        check = {
          command = "clippy";
          workspace = false;
        };
      };
    };
  };
}
