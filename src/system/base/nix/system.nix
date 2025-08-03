{ inputs, config, pkgs, lib, ... }:

{
  nix.registry = {
    pkgs.flake = inputs.self;
    p.flake = inputs.self;
  };
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  environment.systemPackages = [ pkgs.nh ];
}
