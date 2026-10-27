{ pkgs, lib, ... }:

{
  nix.package = lib.mkForce pkgs.lix;
}
