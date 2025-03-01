{ pkgs, ... }:

{
  opts = {
    system = {
      filesystem.drive = "/dev/nvme1n1";
      profile = "users.timon";
      hardware.gpu.nvidia = {
        enable = true;
        monitorDdcciFixEnable = true;
      };
      network.wifi.enable = true;
    };
    users = {
      timon = {
        home = {
          apps.other.steam.enable = true;
        };
      };
    };
  };

  boot = {
    initrd = {
      availableKernelModules = [ "nvme" "xhci_pci" "ahci" "usbhid" "usb_storage" "sd_mod" ];
      kernelModules = [ "dm-snapshot" ];
    };
    kernelModules = [ "kvm-amd" ];
  };

  hardware = {
    enableRedistributableFirmware = true;
    cpu.amd.updateMicrocode = true;
  };

  # disable the tpm module because it not supported and causes failures during boot
  boot.blacklistedKernelModules = [ "tpm" "tpm_atmel" "tpm_infineon" "tpm_nsc" "tpm_tis" "tpm_crb" ];

}
