{ pkgs, ... }:

let
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
    utils = {
      calculator.enable = true;
    };
    other = {
      signal.enable = true;
      discord-webcord.enable = true;
      spotify.enable = true;
    };
  };
in

{
  opts = {
    system = {
      drive = "/dev/disk/by-id/ata-SAMSUNG_MZNLF128HCHP-00000_S28TNXAGB25148";
      swap.size = "16G";
      hardware.gpu.nvidia = {
        enable = true;
        monitorDdcciFixEnable = true;
      };
      desktops.gnome.enable = true;
    };
    users = {
      wiebke = {
        passwordHash = "$6$rounds=262144$btdA4Fl2MtXbCcEw$wzDDnSCaBlgUYNIXQm0fK8dKjHQAPFP6AiQz6qpZi3l9/h69WmbMAhSNtPYN5qSGcEw4yJGQT4W0KdPFvAcYg0";
        home = {
          name = "Wiebke";
          email = "wiebke.users@timon.zip";
          persist.data.folders = [
            "data"
            "tmp"
          ];
          desktops.gnome.mac.enable = true;
          profiles.default-desktop-apps.enable = true;
          inherit apps;
        };
      };
      timon = {
        passwordHash = "$6$rounds=262144$btdA4Fl2MtXbCcEw$wzDDnSCaBlgUYNIXQm0fK8dKjHQAPFP6AiQz6qpZi3l9/h69WmbMAhSNtPYN5qSGcEw4yJGQT4W0KdPFvAcYg0";
        admin = true;
        home = {
          name = "Timon Schelling";
          email = "me@timon.zip";
          profiles.default-desktop-apps.enable = true;
          persist.data.folders = [
            "tmp"
          ];
          desktops.gnome.mac.enable = true;
          inherit apps;
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

  # disable the tpm module because it not supported and causes failures during boot
  boot.blacklistedKernelModules = [ "tpm" "tpm_atmel" "tpm_infineon" "tpm_nsc" "tpm_tis" "tpm_crb" ];

  # steam
  # hardware.graphics.enable32Bit = true; should be set in nvidia module
  opts.users.wiebke.home.persist.state.folders = [ ".local/share/Steam" ];
  home-manager.users.timon.home.packages = [ pkgs.steam ];
  # for unity games set data folder with `XDG_CONFIG_HOME=~/.local/share/Steam/data %command%` in steam launch options
}