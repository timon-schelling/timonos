{  pkgs, lib, ... }:

{
  platform.user.persist.folders = [
    ".cache/cliphist"
  ];

  home.packages = [
    pkgs.wl-clipboard
    pkgs.cliphist
    (pkgs.nu.writeScriptBin "clipboard-history" ''
      alias clip = ${pkgs.cliphist}/bin/cliphist
      clip list | select-ui | clip decode | ${pkgs.wl-clipboard}/bin/wl-copy
    '')
  ];

  wayland.windowManager.hyprland.extraConfig = lib.mkAfter ''
    exec-once = ${pkgs.wl-clipboard}/bin/wl-paste --watch ${pkgs.cliphist}/bin/cliphist store
  '';

  # platform.user.persist.folders = [
  #   ".cache/clipcat"
  # ];

  # home.packages = [
  #   pkgs.clipcat
  #   pkgs.wl-clipboard-rs
  #   (pkgs.nu.writeScriptBin "clipboard-history" ''
  #     let clipboard = (clipcatctl list | split list "\n" | each { |x| $x | parse --regex '(?P<id>\w*)\: (?P<text>.*)' }).0
  #     let selection = ($clipboard | get text | str join "\n" | select-ui)
  #     let selection_id = ($clipboard | where { |x| $x.text == $selection }).0.id
  #     clipcatctl get $selection_id | wl-copy
  #   '')
  # ];

  # systemd.user.services.clipcatd = {
  #   Unit = {
  #     Description = "Clipboard deamon";
  #     PartOf = [ "graphical-session.target" ];
  #   };
  #   Install.WantedBy = [ "graphical-session.target" ];
  #   Service = {
  #     ExecStart = "${(pkgs.nu.writeScript "clipcatd-start" ''
  #       mkdir ~/.config/clipcat
  #       ${pkgs.clipcat}/bin/clipcatd default-config
  #         | from toml
  #         | update max_history 10000
  #         | update desktop_notification.enable false
  #         | update metrics.enable false
  #         | update grpc.enable_http false
  #         | to toml
  #         | save -f ~/.config/clipcat/clipcatd.toml
  #       ${pkgs.clipcat}/bin/clipcatd --no-daemon --replace
  #     '')}";
  #     Restart = "on-failure";
  #     Type = "simple";
  #   };
  # };
}
