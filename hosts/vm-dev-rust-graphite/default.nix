{ lib, pkgs, config, ... }:

let
  graphiteSrc = pkgs.fetchFromGitHub {
    owner = "GraphiteEditor";
    repo = "Graphite";
    rev = "80f38d91c0c8f280d2559cc43c99e38f58c8e1ff";
    hash = "sha256-o2arVCZtH0yv58KRhaO/WQCXED65vGX+jR7CK1u26Ik=";
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
    ../vm-base-git
    ../vm-base-persist
    ../vm-base-lang-rust
  ];

  config = {

    opts.users.user.home.persist.state.folders = [
      "target"
      ".cargo"
    ];

    home-manager.users.user.programs.nushell.extraConfig = lib.mkAfter ''
      source ${nuEnv}

      $env.CARGO_TARGET_DIR = $"($env.HOME)/target"
    '';

    environment.systemPackages = [
      pkgs.cargo-about
    ];
  };
}
