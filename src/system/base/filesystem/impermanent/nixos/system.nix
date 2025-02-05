{ ... }:

{
  # needed for uid/gid persistence in nixos
  platform.system.persist.folders = [ "/var/lib/nixos" ];

  # needed for systemd and some programs that need a persistent machine id
  platform.system.persist.files = [ "/etc/machine-id" ];
}
