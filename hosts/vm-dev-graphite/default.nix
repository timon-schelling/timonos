{ lib, pkgs, ... }:

{
  imports = [
    ../vm-base
    ../vm-base-workspace
    ../vm-base-vcs
    ../vm-base-persist
    ../vm-base-ai-tools
    ../vm-base-rust-rover
  ];

  config =
    let
      rev = "baf2403d7e6a55efd39ec0ddf086d9d366b3472f";
      # Update with `nix flake metadata --json github:GraphiteEditor/Graphite/<new-rev>`
      hash = "sha256-JdsmjVGtOJpK+xCnsE9BXRbZaKNhGXoIhxffpDsFjCI=";
      flake = builtins.getFlake "github:GraphiteEditor/Graphite/${rev}?narHash=${hash}";
      devShell = flake.devShells.${pkgs.stdenv.hostPlatform.system}.default.override {
        desktop = true;
        playwright = true;
      };
      basePackages = devShell.buildInputs ++ devShell.nativeBuildInputs ++ [ (pkgs.useWildLinker pkgs.stdenv).cc ];
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
          pkgs.vscode-extensions.rust-lang.rust-analyzer
          pkgs.vscode-extensions.vadimcn.vscode-lldb
          pkgs.vscode-extensions.tamasfe.even-better-toml
          pkgs.vscode-extensions.wgsl-analyzer.wgsl-analyzer
          pkgs.vscode-extensions.svelte.svelte-vscode
          pkgs.vscode-extensions.dbaeumer.vscode-eslint
          pkgs.vscode-extensions.esbenp.prettier-vscode
          pkgs.vscode-extensions.vitaliymaz.vscode-svg-previewer
          pkgs.vscode-extensions.jgclark.vscode-todo-highlight
        ];
        userSettings."rust-analyzer.cargo.targetDir" = true;
      };

      home-manager.users.user.programs.zed-editor = {
        extensions = [ "wgsl" "svelte" "toml" ];
        userSettings.lsp."rust-analyzer".initialization_options.cargo.targetDir = true;
      };

      home-manager.users.user.opts.user.persist.state.folders = [
        ".cargo"
      ];

      # services.desktopManager.plasma6.enable = true;
      # services.flatpak.enable = true;
    };
}
