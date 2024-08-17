{ pkgs, ... }:

{
  platform.system.persist.files = [ "/etc/machine-id" ];
  system.activationScripts.machine-id = {
    deps = [ "persist-files" ];
    text = ''
      ${pkgs.systemd}/bin/systemd-machine-id-setup
    '';
  };
}
