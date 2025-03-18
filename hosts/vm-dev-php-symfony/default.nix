{ pkgs, lib, config, ... }:

{
  imports = [
    ../vm-base
    ../vm-base-workspace
    ../vm-base-persist
  ];

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
  users.users.timon.extraGroups = [ "docker" ];

  opts.users.timon.home.persist.state.folders = [ ".cache/composer" ];
  environment.systemPackages = [
    (pkgs.php84.buildEnv {
      extensions = { enabled, all }:
        enabled ++ (with all; [
          bcmath
          gd
          intl
          pdo_mysql
          zip
          simplexml
        ]);
    })
    pkgs.php84Packages.composer
    (pkgs.callPackage ./symfony-cli-package.nix {})
  ];

  home-manager.users.timon.programs.vscode.profiles.default.extensions = pkgs.vscode-utils.extensionsFromVscodeMarketplace [
    {
      publisher = "zobo";
      name = "php-intellisense";
      version = "1.3.3";
      sha256 = "sha256-VmcYEUsNfkYtFKoC4fOq4p6EZPxhCE8yHzqAT8Bityo=";
    }
  ];
}
