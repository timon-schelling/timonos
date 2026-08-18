{ ... }:

{
  opts = {
    system = {
      filesystem.drive = "/dev/nvme1n1";
      profile = "users.timon";
      hardware = {
        gpu.nvidia = {
          enable = true;
          monitorDdcciFixEnable = true;
        };
        bluetooth.enable = true;
        automount.enable = true;
      };
      network = {
        wifi.enable = true;
        routeViaGateway = [ "10.0.0.0/8" "fd00::/8" ];
      };
    };
    users = {
      timon = {
        home = {
          apps.media.krita.enable = true;
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

  # Remote access setup
  opts.system.network.tailscale.enable = true;
  opts.system.persist = {
    files = [
      "/etc/ssh/ssh_host_ed25519_key"
      "/etc/ssh/ssh_host_ed25519_key.pub"
    ];
  };
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = true;
      PermitRootLogin = "no";
    };
    hostKeys = [
      {
        path = "/etc/ssh/ssh_host_ed25519_key";
        type = "ed25519";
      }
    ];
  };
}
