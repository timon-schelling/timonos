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
    };
    network.wifi.enable = true;
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
    "niri".configuration = {
      opts.system.desktops = {
        hyprland.enable = lib.mkForce false;
        niri.enable = true;
      };
      opts.users.timon.home.desktops = {
        hyprland.rainbow.enable = false;
        niri.rainbow.enable = true;
      };
      system.nixos.tags = [ "niri" ];
    };
  };
}
