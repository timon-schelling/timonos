{ inputs, config, pkgs, lib, ... }:

{
  nix.settings.substituters = [
    "https://nix-community.cachix.org"
    "https://graphite.cachix.org"
    "https://graphite-dev.cachix.org"
  ];
  nix.settings.trusted-public-keys = [
    "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    "graphite.cachix.org-1:B7Il1yMpkquN/dXM+5GRmz+4Xmu2aaCS1GcWNfFhsOo="
    "graphite-dev.cachix.org-1:RppXYpiV1qO2TYKTkXXGHsAEQDOB5G51b3VlrN9QmbI="
  ];
  nix.registry = {
    pkgs.flake = inputs.self;
    p.flake = inputs.self;
  };
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  environment.systemPackages = [ pkgs.nh ];
}
