{ config, pkgs, ... }:

{
  platform.user.persist.folders = [
    ".config/Bitwarden"
  ];

  home.packages = [
    # TODO: Change back once https://github.com/NixOS/nixpkgs/issues/526914 is resolved
    (pkgs.bitwarden-desktop.override { electron_39 = pkgs.electron_39-bin; })
  ];
}
