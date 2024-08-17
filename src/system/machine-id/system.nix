{ ... }:

{
  platform.system.persist.files = [ "/etc/machine-id" ];
  system.activationScripts.machine-id = {
    deps = [ "etc" ];
    text = "systemd-machine-id-setup";
  };
}
