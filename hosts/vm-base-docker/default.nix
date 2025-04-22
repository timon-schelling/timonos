{ pkgs, lib, config, ... }:

{
  opts.system.persist.folders = [
    "/var/lib/docker"
  ];
  virtualisation.docker = {
    enable = true;
    package = pkgs.docker.overrideAttrs (oldAttrs: {
      postPatch = ''
        patchShebangs man scripts/build/
        substituteInPlace ./scripts/build/.variables --replace-fail "set -eu" ""
        substituteInPlace ./cli-plugins/manager/manager_unix.go --replace-fail /usr/libexec/docker/cli-plugins \
            "${pkgs.symlinkJoin {
              name = "docker-plugins";
              paths = [
                pkgs.docker-compose
                pkgs.docker-buildx
                (pkgs.callPackage ./docker-lock-package.nix {})
              ];
            }}/libexec/docker/cli-plugins"
      '';
    });
  };
  users.users.user.extraGroups = [ "docker" ];
}
