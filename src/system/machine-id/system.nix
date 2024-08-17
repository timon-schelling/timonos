{ pkgs, ... }:

{
  platform.system.persist.files = [ "/etc/machine-id" ];
  system.activationScripts.machine-id = {
    deps = [ "etc" ];
    text = ''
      ${pkgs.systemd}/bin/systemd-machine-id-setup
    '';
  };
}
