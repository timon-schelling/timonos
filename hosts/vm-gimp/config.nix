{ lib, pkgs, config, ... }:

{
  imports = [
    ../vm-base
    ../vm-base-workspace
    ../vm-base-persist
  ];

  config = {
    opts.users.timon.home.persist.state.folders = [
      ".config/GIMP"
      ".local/share/GIMP"
      ".cache/GIMP"
    ];

    environment.systemPackages = [
      (pkgs.appimageTools.wrapType2 {
        name = "gimp";
        src = pkgs.fetchurl {
          url = "https://download.gimp.org/gimp/v3.0/linux/GIMP-3.0.0-RC3-x86_64.AppImage";
          hash = "sha256-OD9iXtN6LW0uXCK6rS8+O2xQ081RnrbgkGmQN4O8rHo=";
        };
      })
    ];
  };
}
