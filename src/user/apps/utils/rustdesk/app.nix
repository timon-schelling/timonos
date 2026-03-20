{ pkgs, ... }:

{
  platform.user.persist.folders = [
    ".config/rustdesk"
  ];

  home.packages = [
    pkgs.rustdesk-flutter
  ];
}
