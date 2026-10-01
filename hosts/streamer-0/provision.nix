{ config, lib, ... }:

let
  firmware = "/boot/firmware";
  cfg = "${firmware}/config";
in
{
  fileSystems.${firmware}.options = lib.mkForce [
    "nofail"
    "noauto"
    "umask=0077"
  ];

  systemd.services.firmware-provision = {
    description = "Import settings from firmware partition";
    wantedBy = [ "multi-user.target" ];
    before = [
      "iwd.service"
      "avahi-daemon.service"
      "librespot.service"
      "shairport-sync.service"
    ];
    unitConfig.RequiresMountsFor = firmware;
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      shopt -s nullglob
      umask 077

      mkdir -p /var/lib/iwd
      for src in ${cfg}/wifi/*.psk ${cfg}/wifi/*.open ${cfg}/wifi/*.8021x; do
        dst="/var/lib/iwd/$(basename "$src")"
        if [ ! -e "$dst" ] || [ "$src" -nt "$dst" ]; then
          tr -d '\r' < "$src" > "$dst.tmp"
          touch -r "$src" "$dst.tmp"
          mv "$dst.tmp" "$dst"
          echo "imported wifi network $(basename "$src")"
        fi
      done

      if [ -f ${cfg}/tailscale-authkey ]; then
        tr -d '[:space:]' < ${cfg}/tailscale-authkey > "/run/tailscale-authkey"
      fi

      name=$(tr -d '[:space:]' < ${cfg}/hostname 2>/dev/null || true)
      [ -n "$name" ] || name=${config.opts.system.host}
      echo "$name" > /proc/sys/kernel/hostname
    '';
  };
  networking.hostName = lib.mkForce "";

  services.tailscale = {
    authKeyFile = "/run/tailscale-authkey";
    extraSetFlags = [ "--ssh" ];
  };
  systemd.services.tailscaled-autoconnect = {
    after = [ "firmware-provision.service" ];
    wants = [ "firmware-provision.service" ];
    unitConfig.ConditionPathExists = "/run/tailscale-authkey";
  };

  services.usbmuxd.enable = true;
}
