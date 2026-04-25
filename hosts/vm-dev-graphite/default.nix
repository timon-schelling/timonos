{ lib, pkgs, ... }:

{
  imports = [
    ../vm-base
    ../vm-base-workspace
    ../vm-base-vcs
    ../vm-base-persist
  ];

  config =
    let
      rev = "3c04c2bb8bc9edc725d3a1abe3580cd52e5359c5";
      # Update with `nix flake metadata --json github:GraphiteEditor/Graphite/<new-rev>`
      hash = "sha256-ubY6YP5GKxKl6ogoKzHxjBaKRKo4oR1D524+gE1e1MQ=";
      flake = builtins.getFlake "github:GraphiteEditor/Graphite/${rev}?narHash=${hash}";
      devShell = flake.devShells.${pkgs.stdenv.hostPlatform.system}.default;
      basePackages = devShell.buildInputs ++ devShell.nativeBuildInputs ++ [ pkgs.stdenv.cc ];
      packages = builtins.concatMap (
        pkg:
          if builtins.isAttrs pkg && builtins.hasAttr "out" pkg then
            [ pkg pkg.out ]
          else
            [ pkg ]
      ) basePackages;
      sessionVariables = lib.filterAttrs (
        name: value:
          builtins.match "^[A-Z_][A-Z0-9_]*$" name != null
          && value != null
      ) devShell;
    in
    {
      environment.systemPackages = packages;
      environment.sessionVariables = lib.mapAttrs (_: value: lib.mkForce value) sessionVariables;
      home-manager.users.user.programs.vscode.profiles.default = {
        extensions = [
          pkgs.vscode-extension-wgsl-analyzer
          pkgs.vscode-extensions.rust-lang.rust-analyzer
          pkgs.vscode-extensions.vadimcn.vscode-lldb
          pkgs.vscode-extensions.tamasfe.even-better-toml
          pkgs.vscode-extensions.svelte.svelte-vscode
          pkgs.vscode-extensions.dbaeumer.vscode-eslint
          pkgs.vscode-extensions.esbenp.prettier-vscode
          pkgs.vscode-extensions.vitaliymaz.vscode-svg-previewer
          pkgs.vscode-extensions.jgclark.vscode-todo-highlight
        ];
        userSettings."rust-analyzer.cargo.targetDir" = true;
      };

      opts.users.user.home.persist.state.folders = [ ".cargo" ];

      # services.desktopManager.plasma6.enable = true;
      # services.flatpak.enable = true;
    };
}
