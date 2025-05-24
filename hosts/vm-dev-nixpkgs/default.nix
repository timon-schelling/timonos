{ lib, pkgs, config, ... }:

{
  imports = [
    ../vm-base
    ../vm-base-persist
    ../vm-base-lang-rust
  ];

  config = {

    contain.config = {
      cpu = {
        cores = 32;
      };
      memory = {
        size = 28000;
      };
    };

    opts.users.user.home.persist.data.folders = [
      "workspace"
    ];

    home-manager.users.user.programs.nushell.extraConfig = lib.mkAfter ''
      if ((pwd) == $env.HOME) and not ("SUDO_COMMAND" in $env) {
        e ~/workspace
      }
    '';

    environment.systemPackages = [
      pkgs.nixpkgs-review
      pkgs.nixpkgs-vet
      pkgs.nixpkgs-fmt
      pkgs.nixpkgs-lint
    ];
  };
}
