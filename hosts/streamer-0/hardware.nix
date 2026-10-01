{ config, lib, pkgs, modulesPath, ... }:

let
  configTxt = pkgs.writeText "config.txt" ''
    kernel=u-boot.bin
    enable_uart=1
    core_freq=400
    core_freq_min=400
    gpu_mem=32
    disable_splash=1
    avoid_warnings=1
  '';

  firmwareReadme = pkgs.writeText "README.md" ''
    `tailscale-authkey`: auth key from https://login.tailscale.com/admin/settings/keys
    `hostname`: hostname, Spotify Connect and AirPlay name
    `wifi/<SSID>.psk`: iwd network file
    ```
    [Security]
    Passphrase=...
    ```
  '';
in
{
  imports = [
    "${modulesPath}/installer/sd-card/sd-image.nix"
  ];

  nixpkgs.buildPlatform = "x86_64-linux";

  boot = {
    loader = {
      systemd-boot.enable = lib.mkForce false;
      efi.canTouchEfiVariables = lib.mkForce false;
      grub.enable = false;
      generic-extlinux-compatible.enable = true;
    };

    extraModulePackages = lib.mkForce [ ];
    kernelModules = lib.mkForce [ "tun" "i2c-dev" ];
    blacklistedKernelModules = [ "vc4" "snd_bcm2835" "bluetooth" "hci_uart" "btbcm" ];
    consoleLogLevel = 4;
    extraModprobeConfig = "options cfg80211 ieee80211_regdom=DE";
    kernelParams = [ "udev.children_max=2" "rd.udev.children_max=2" ];

    kernelPatches = [
      {
        name = "preempt";
        patch = null;
        structuredExtraConfig = with lib.kernel; {
          PREEMPT = lib.mkForce yes;
          PREEMPT_VOLUNTARY = lib.mkForce no;
        };
      }
      {
        name = "builtin-drivers";
        patch = null;
        structuredExtraConfig = with lib.kernel; {
          MMC = lib.mkForce yes;
          RPMB = lib.mkForce yes;
          MMC_BLOCK = lib.mkForce yes;
          MMC_BCM2835 = lib.mkForce yes;
          MMC_SDHCI = lib.mkForce yes;
          MMC_SDHCI_PLTFM = lib.mkForce yes;
          MMC_SDHCI_IPROC = lib.mkForce yes;
          EXT4_FS = lib.mkForce yes;
          VFAT_FS = lib.mkForce yes;
          NLS_CODEPAGE_437 = lib.mkForce yes;
          NLS_ISO8859_1 = lib.mkForce yes;
          I2C_BCM2835 = lib.mkForce yes;
          I2C_CHARDEV = lib.mkForce yes;
          SOUND = lib.mkForce yes;
          SND = lib.mkForce yes;
          SND_SOC = lib.mkForce yes;
          SND_BCM2835_SOC_I2S = lib.mkForce yes;
          SND_SOC_PCM512x_I2C = lib.mkForce yes;
          SND_SIMPLE_CARD = lib.mkForce yes;
          USB_DWC2 = lib.mkForce yes;
          TUN = lib.mkForce yes;
          MODULE_COMPRESS = lib.mkForce no;
          MODULE_COMPRESS_XZ = lib.mkForce (option no);
          MODULE_COMPRESS_ALL = lib.mkForce (option no);
        };
      }
    ];

    initrd = {
      includeDefaultModules = false;
      availableKernelModules = [ "mmc_block" "sdhci_iproc" "bcm2835" ];
      allowMissingModules = true;
      systemd.tpm2.enable = false;
    };
  };
  fileSystems."/".noCheck = true;

  hardware = {
    enableAllHardware = lib.mkForce false;
    enableRedistributableFirmware = lib.mkForce false;
    firmware = [ pkgs.raspberrypiWirelessFirmware ];
    wirelessRegulatoryDatabase = true;

    deviceTree = {
      enable = true;
      filter = "bcm2835-rpi-zero-w.dtb";
      name = "bcm2835-rpi-zero-w.dtb";
      overlays = [
        {
          name = "disable-vc4-hdmi";
          dtsText = ''
            /dts-v1/;
            /plugin/;
            / {
              compatible = "brcm,bcm2835";
            };
            &vc4 {
              status = "disabled";
            };
            &hdmi {
              status = "disabled";
            };
          '';
        }
        {
          name = "disable-bluetooth";
          dtsText = ''
            /dts-v1/;
            /plugin/;
            / {
              compatible = "brcm,bcm2835";
            };
            &uart0 {
              status = "disabled";
            };
          '';
        }
      ];
    };
  };

  sdImage = {
    populateFirmwareCommands = ''
      (cd ${pkgs.raspberrypifw}/share/raspberrypi/boot && cp bootcode.bin fixup*.dat start*.elf $NIX_BUILD_TOP/firmware/)
      cp ${pkgs.raspberrypifw}/share/raspberrypi/boot/bcm2708-rpi-zero-w.dtb firmware/
      cp ${pkgs.ubootRaspberryPi}/u-boot.bin firmware/u-boot.bin
      cp ${configTxt} firmware/config.txt
      mkdir -p firmware/config/wifi
      cp ${firmwareReadme} firmware/config/README.md
    '';
    populateRootCommands = ''
      mkdir -p ./files/boot
      ${config.boot.loader.generic-extlinux-compatible.populateCmd} -c ${config.system.build.toplevel} -d ./files/boot
    '';
  };

  fonts = {
    fontconfig.enable = lib.mkForce false;
    packages = lib.mkForce [ ];
  };
  security.polkit.enable = lib.mkForce false;
  environment.shells = lib.mkForce [ pkgs.bashInteractive ];
  system.disableInstallerTools = true;
  documentation.enable = false;
  programs.command-not-found.enable = false;
  programs.bash.completion.enable = false;
  services.lvm.enable = false;
  boot.bcache.enable = false;
  services.fstrim.enable = false;
  services.journald.settings.Journal.Storage = "volatile";
  services.logrotate.enable = false;
  systemd.oomd.enable = false;
  networking.nftables.enable = true;
  networking.firewall.checkReversePath = "loose";
  systemd.units = {
    "systemd-rfkill.service".enable = false;
    "systemd-rfkill.socket".enable = false;
    "modprobe@efi_pstore.service".enable = false;
    "sys-kernel-debug.mount".enable = false;
    "sys-kernel-tracing.mount".enable = false;
  };
  nix.channel.enable = false;
  environment.defaultPackages = [ ];
  console.enable = false;
  i18n.supportedLocales = [ "en_US.UTF-8/UTF-8" ];
  xdg = {
    mime.enable = false;
    icons.enable = false;
    sounds.enable = false;
    menus.enable = false;
    autostart.enable = false;
  };
}
