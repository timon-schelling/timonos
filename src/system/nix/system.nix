{ config, pkgs, ... }:

{
  system.stateVersion = config.opts.system.stateVersion;
  nixpkgs.hostPlatform = config.opts.system.platform;
  nixpkgs.config.allowUnfree = true;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  environment.systemPackages = [ pkgs.nh ];
}
