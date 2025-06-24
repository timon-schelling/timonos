{ lib, pkgs, config, ... }:

let
  graphiteSrc = pkgs.fetchFromGitHub {
    owner = "GraphiteEditor";
    repo = "Graphite";
    rev = "10907707c2cf462db52b6414fda98ed23effcf85";
    hash = "sha256-y+ArPV9dtoi3c4J9cwFpDy6665VcLyzKC9GDvTqdUNo=";
  };
  graphiteFlakeSrc = pkgs.stdenv.mkDerivation {
    src = graphiteSrc;
    name = "graphite-flake";
    nativeBuildInputs = [ pkgs.jq ];
    phases = [ "unpackPhase" "buildPhase" "installPhase" ];
    buildPhase = ''
      cp ".nix/flake.nix" flake.nix
      jq 'del(.. | .lastModified?)' ".nix/flake.lock" > flake.lock
    '';
    installPhase = ''
      mkdir -p $out
      cp flake.nix $out/flake.nix
      cp flake.lock $out/flake.lock
    '';
  };

  flakeCompat = pkgs.fetchFromGitHub {
    owner = "edolstra";
    repo = "flake-compat";
    rev = "9100a0f413b0c601e0533d1d94ffd501ce2e7885";
    hash = "sha256-CIVLLkVgvHYbgI2UpXvIIBJ12HWgX+fjA8Xf8PUmqCY=";
  };

  getFlake = src: import flakeCompat { inherit src; };

  bashShell = (getFlake graphiteFlakeSrc).outputs.devShells.${pkgs.system}.default;

  nuEnv = pkgs.nu.envFromDrv bashShell {
    postEnvLoadCommands = ''
      $env.WEBKIT_DISABLE_DMABUF_RENDERER = 1

      alias cargo = mold --run cargo
    '';
  };
in
{
  imports = [
    ../vm-base
    ../vm-base-workspace
    ../vm-base-vcs
    ../vm-base-lang-rust
  ];

  config = {
    home-manager.users.user.programs.nushell.extraConfig = lib.mkAfter ''
      source ${nuEnv}
    '';
  };
}
