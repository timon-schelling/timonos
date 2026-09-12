{ lib, ... }:

{
  opts.system = {
    filesystem.drive = "/dev/disk/by-id/nvme-MTFDKBA1T0TFH-1BC1AABHA_UMDMD0153GYBFB";
    profile = "users.timon";
    hardware = {
      gpu.nvidia-intel-mobile = {
        enable = true;
        mode = "integrated";
        nvidiaBusId = "PCI:1:0:0";
        intelBusId = "PCI:0:2:0";
      };
      bluetooth.enable = true;
      automount.enable = true;
      fingerprint.enable = true;
    };
    network = {
      wifi.enable = true;
      tailscale.enable = true;
    };
    sudo.timeout = 0;
  };

  boot = {
    initrd = {
      availableKernelModules = [ "nvme" "xhci_pci" "usbhid" "thunderbolt" ];
      kernelModules = [ "dm-snapshot" ];
    };
    kernelModules = [ "kvm-intel" ];
  };

  hardware = {
    enableRedistributableFirmware = true;
    cpu.intel.updateMicrocode = true;
  };

  specialisation = {
    "hybrid-gpu".configuration = {
      opts.system.hardware.gpu.nvidia-intel-mobile.mode = lib.mkForce "hybrid";
      system.nixos.tags = [ "hybrid-gpu" ];
    };
  };
}
