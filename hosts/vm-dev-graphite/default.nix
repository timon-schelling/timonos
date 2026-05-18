{ lib, pkgs, ... }:

{
  imports = [
    ../vm-base
    ../vm-base-workspace
    ../vm-base-vcs
    ../vm-base-persist
    ../vm-base-ai-tools
  ];

  config =
    let
      rev = "d5f0140f268ec65d732fdc034eeb3c520e84ba49";
      # Update with `nix flake metadata --json github:GraphiteEditor/Graphite/<new-rev>`
      hash = "sha256-80UW1GPYjzTstq8xqOdVgq/e/66Hn658y6xpG9HtbbU=";
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

      home-manager.users.user.opts.user.persist.state.folders = [
        ".cargo"
      ];

      # services.desktopManager.plasma6.enable = true;
      # services.flatpak.enable = true;
    };
}
