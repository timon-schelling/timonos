{
  opts = {
    system = {
      filesystem = {
        drive = "/dev/disk/by-id/ata-SAMSUNG_MZNLN256HMHQ-000H1_S2Y2NX0HC43252";
        swap.size = "16G";
      };
      network.wifi.enable = true;
      desktops.gnome.enable = true;
    };
    users = {
      timon = {
        passwordHash = "$6$rounds=262144$btdA4Fl2MtXbCcEw$wzDDnSCaBlgUYNIXQm0fK8dKjHQAPFP6AiQz6qpZi3l9/h69WmbMAhSNtPYN5qSGcEw4yJGQT4W0KdPFvAcYg0";
        admin = true;
        home = {
          name = "Timon Schelling";
          email = "me@timon.zip";
          profiles.default-desktop-apps.enable = true;
          persist.data.folders = [
            "tmp"
            "data"
          ];
          desktops.gnome.mac.enable = true;
          apps = {
            terminal = {
              rio.enable = true;
            };
            settings = {
              wifi.enable = true;
              audio.enable = true;
            };
            editor = {
              vscode.enable = true;
            };
            browser = {
              firefox.enable = true;
              chromium.enable = true;
              epiphany.enable = true;
            };
            filemanager = {
              nautilus.enable = true;
            };
            media = {
              spotify.enable = true;
            };
          };
        };
      };
    };
  };

  services.upower.ignoreLid = true;
  services.logind.lidSwitch = "ignore";

  # TODO: find a better way
  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = true;
  };

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  boot = {
    kernelModules = [ "kvm-intel" ];
    initrd = {
      kernelModules = [ "amdgpu" ];
      availableKernelModules = [ "xhci_pci" "ahci" "ehci_pci" "usb_storage" "sd_mod" "sr_mod" "sdhci_pci" ];
    };
  };

  hardware = {
    enableRedistributableFirmware = true;
    cpu.amd.updateMicrocode = true;
  };

  # disable the tpm module because it not supported and causes failures during boot
  boot.blacklistedKernelModules = [ "tpm" "tpm_atmel" "tpm_infineon" "tpm_nsc" "tpm_tis" "tpm_crb" ];

  imports = [
    ./smarthome-containers.nix
  ];
}
