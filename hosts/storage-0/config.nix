{
  opts = {
    system = {
      drive = "/dev/disk/by-id/ata-SAMSUNG_MZNLF128HCHP-00000_S28TNXAGB25148";
      swap.size = "16G";
    };
    users = {
      user = {
        passwordHash = "$6$rounds=262144$qsdAwOt1Y50jB7oF$0oYPN0qt7pm7Dv4qD75o.gOD28THHSxNxGWRMGAdbOgQ6H.if236GYIyTVe.n502fSSCZ.MYEY0RtBCqerhvF1";
        admin = true;
        home = {
          name = "User";
          email = "user.storage-0.homelab@timon.zip";
          persist.data.folders = [
            "tmp"
          ];
        };
      };
    };
  };

  services.openssh = {
    enable = true;
    passwordAuthentication = true;
  };

  boot = {
    initrd.availableKernelModules = [ "xhci_pci" "ahci" "usbhid" "ums_realtek" "usb_storage" "sd_mod" "sr_mod" ];
    kernelModules = [ "kvm-intel" ];
  };

  hardware = {
    enableRedistributableFirmware = true;
    cpu.intel.updateMicrocode = true;
  };
}
