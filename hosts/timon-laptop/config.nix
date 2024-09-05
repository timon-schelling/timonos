{ lib, pkgs, ... }:

{
  imports = [
    ./gpu.nix
  ];

  opts = {
    system = {
      drive = "/dev/disk/by-id/nvme-MTFDKBA1T0TFH-1BC1AABHA_UMDMD0153GYBFB";
      platform = "x86_64-linux";
      hardware.gpu.nvidia.mobile.mode = "integrated";
    };
    users = {
      timon = {
        passwordHash = "$6$rounds=262144$btdA4Fl2MtXbCcEw$wzDDnSCaBlgUYNIXQm0fK8dKjHQAPFP6AiQz6qpZi3l9/h69WmbMAhSNtPYN5qSGcEw4yJGQT4W0KdPFvAcYg0";
        admin = true;
        home = {
          name = "Timon Schelling";
          email = "me@timon.zip";
          persist.data.folders = [
            "code"
            "data"
            "media"
            "tmp"
          ];
          profile = "personal";
        };
      };
    };
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
