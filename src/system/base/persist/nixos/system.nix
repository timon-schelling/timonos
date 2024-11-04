{ ... }:

{
  # needed for uid/gid persistence in nixos
  platform.system.persist.folders = [ "/var/lib/nixos" ];

  # needed for systemd and some programs that need a persistent machine id
  platform.system.persist.files = [ "/etc/machine-id" ];

  # TODO: remove this once we have a proper solution for this
  # see https://github.com/nix-community/impermanence/issues/229
  systemd.suppressedSystemUnits = ["systemd-machine-id-commit.service"];
}
