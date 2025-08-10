{ lib, pkgs, config, ... }:

{
  imports = [
    ../vm-base
    ../vm-base-workspace
    ../vm-base-persist
  ];

  config = {
    contain.config = {
      cpu = {
        cores = 32;
      };
      memory = {
        size = 32000;
      };
    };

    opts.users.user.home.persist.state.folders = [
      ".config/GIMP"
      ".local/share/GIMP"
      ".cache/GIMP"
    ];

    environment.systemPackages = [
      pkgs.gimp3
    ];
  };
}
