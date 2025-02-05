{
  opts = {
    system = {
      filesystem = {
        filesystem.drive = "/dev/disk/by-id/ata-SAMSUNG_MZNLF128HCHP-00000_S28TNXAGB25148";
        swap.size = "16G";
      };
      hardware.gpu.nvidia = {
        enable = true;
        monitorDdcciFixEnable = true;
      };
      desktops.hyprland.enable = true;
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
          desktops.hyprland.rainbow.enable = true;
          profiles.default-desktop-apps.enable = true;
        };
      };
    };
  };

  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = true;
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
