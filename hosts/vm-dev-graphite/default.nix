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
      rev = "f615f9fbd874fff1e43ecbb3a2a1a463ff7b4223";
      # Update with `nix flake metadata --json github:GraphiteEditor/Graphite/<new-rev>`
      hash = "sha256-s2e3Q1k8rS5fhUsb6AQOoYQgZ9WgaLu/3gvETD4GiYM=";
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
      environment.systemPackages = packages ++ [
        pkgs.claude-code
      ];
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
          pkgs.vscode-extensions.anthropic.claude-code
          pkgs.vscode-extension-openai-chatgpt
        ];
        userSettings."rust-analyzer.cargo.targetDir" = true;
      };

      opts.users.user.home.persist.state = {
        folders = [
          ".claude"
          ".cargo"
          ".codex"
        ];
        files = [
          ".claude.json"
        ];
      };

      home-manager.users.user.programs.git.ignores = [
        "CLAUDE.md"
        ".claude"
        ".codex/"
        ".codex"
      ];

      # services.desktopManager.plasma6.enable = true;
      # services.flatpak.enable = true;
    };
}
