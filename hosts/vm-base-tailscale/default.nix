{ ... }:

{
  opts.system.network.tailscale.enable = true;
  boot.initrd.kernelModules = [ "tun" ];
}
