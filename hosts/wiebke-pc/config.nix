{ pkgs, lib, ... }:

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
    media = {
      spotify.enable = true;
    };
    other = {
      signal.enable = true;
      discord-webcord.enable = true;
      steam.enable = true;
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
        passwordHash = "$6$rounds=262144$iqUJl7kM9QWQ7caJ$CCAqlz1iix27sf6Uc//2QOBIK6v.yc8kstK.N2XLvTeMHtkx38qdPPd27QBcraTktwZdfAPqP78cNngtWHicI/";
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
      admin = {
        passwordHash = "$6$rounds=262144$iqUJl7kM9QWQ7caJ$CCAqlz1iix27sf6Uc//2QOBIK6v.yc8kstK.N2XLvTeMHtkx38qdPPd27QBcraTktwZdfAPqP78cNngtWHicI/";
        admin = true;
        home = {
          name = "Admin";
          email = "admin.users@timon.zip";
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

  # TODO: find a better way
  users.users = {
    admin.uid = 1000;
    timon.uid = 1001;
    wiebke.uid = 1002;
  };

  home-manager.users.wiebke = {
    xdg.desktopEntries.files = {
      name = "Data";
      genericName = "Filemanager";
      exec = "${pkgs.nu.writeScript "launch-nautilus-in-home-data" ''
        ${pkgs.nautilus}/bin/nautilus --new-window ($env.HOME + "/data")
      ''}";
      terminal = false;
      icon = "org.gnome.Nautilus";
    };
    # TODO: shoud be done with a generic option for window decoration for all desktops
    programs.firefox.profiles.main.userChrome = lib.mkAfter ''
        .titlebar-buttonbox-container{ display: grid !important }
    '';
  };

  # TODO: find a better way
  console.keyMap = "de";
  services.xserver.xkb.layout = "de";

  # TODO: find a better way
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
}
