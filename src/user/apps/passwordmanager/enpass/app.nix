{ config, pkgs, lib, ... }:

let
  configText = ''
    [General]
    ALWAYS_SAVE_TO_TEAM=local
    ALWAYS_SAVE_TO_VAULT=primary
    ChangedLocationPath=${config.home.homeDirectory}/.local/share/Enpass/
    DEVICE_UUID=00000000-0000-0000-0000-000000000000
    DIALOG_LAST_OPEN_LOCATION=${config.home.homeDirectory}/.local/share
    QUICKSETUP_SHOWN=true
    b2b_user=true
    autorunAtSystemStartup6=false
    avoidSubscriptionDialog=true
    hideDockIconOnClose=false
    useDarkTheme=true

    [Backup]
    changedBackupPath=${config.home.homeDirectory}/.local/share/Enpass/Backups/

    [Browser]
    enableBrowserExtension=false

    [%General]
    autorunAtSystemStartup6=false
    avoidSubscriptionDialog=true
    hideDockIconOnClose=false
    useDarkTheme=true
  '';
  configFile = pkgs.writeText "enpass.conf" configText;
in
{
  platform.user.persist.folders = [
    ".local/share/Enpass"
  ];

  home.activation.enpassConfigCopy = lib.hm.dag.entryAfter ["writeBoundary"] ''
    mkdir -p ${config.home.homeDirectory}/.config/sinew.in
    cp ${configFile} ${config.home.homeDirectory}/.config/sinew.in/Enpass.conf
  '';

  home.packages = [
    pkgs.enpass
  ];
}
