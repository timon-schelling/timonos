{ lib, pkgs, ... }:

{
  imports = [
    ./gpu.nix
  ];

  opts.system = {
    profile = "users.timon";
    drive = "/dev/disk/by-id/nvme-MTFDKBA1T0TFH-1BC1AABHA_UMDMD0153GYBFB";
    hardware.gpu.nvidia.mobile.mode = "integrated";
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
      opts.system.hardware.gpu.nvidia.mobile.mode = lib.mkForce "hybrid";
      system.nixos.tags = [ "hybrid-gpu" ];
    };
  };
}
