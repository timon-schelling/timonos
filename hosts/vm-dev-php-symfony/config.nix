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
  virtualisation.docker.enable = true;
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
}
