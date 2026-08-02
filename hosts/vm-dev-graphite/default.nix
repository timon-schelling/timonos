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
      rev = "95c1ab81f31f318a9e344d1d229feacff861ad39";
      # Update with `nix flake metadata --json github:GraphiteEditor/Graphite/<new-rev>`
      hash = "sha256-0GNoGD0S3YrHAaJ/aPNyVG6SfFi1h1NyTR1xmvd5+DQ=";
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
