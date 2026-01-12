{ inputs, config, pkgs, lib, ... }:

{
  nix.settings.substituters = [
    "https://nix-community.cachix.org"
  ];
  nix.settings.trusted-public-keys = [
    "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
  ];
  nix.registry = {
    pkgs.flake = inputs.self;
    p.flake = inputs.self;
  };
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  environment.systemPackages = [ pkgs.nh ];
}
