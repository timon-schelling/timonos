{ lib, pkgs, config, ... }:

{
  imports = [
    ../vm-base
    ../vm-base-workspace
    ../vm-base-vcs
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

    environment.systemPackages = [
      pkgs.nixpkgs-review
      pkgs.nixpkgs-vet
      pkgs.nixpkgs-fmt
      pkgs.nixpkgs-lint
    ];
  };
}
