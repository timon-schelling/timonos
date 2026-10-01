{ config, lib, pkgs, modulesPath, ... }:

let
  configTxt = pkgs.writeText "config.txt" ''
    kernel=u-boot.bin
    enable_uart=1
    core_freq=250
    gpu_mem=32
    disable_splash=1
    avoid_warnings=1
  '';

  firmwareReadme = pkgs.writeText "README.md" ''
    `tailscale-authkey`: auth key from https://login.tailscale.com/admin/settings/keys
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
    blacklistedKernelModules = [ "vc4" "snd_bcm2835" ];
    consoleLogLevel = 7;

    initrd = {
      availableKernelModules = [ "mmc_block" "sdhci_iproc" "bcm2835" "usbhid" "usb_storage" ];
      allowMissingModules = true;
    };
  };

  hardware = {
    enableAllHardware = lib.mkForce false;
    enableRedistributableFirmware = lib.mkForce false;
    firmware = [ pkgs.raspberrypiWirelessFirmware ];

    deviceTree = {
      enable = true;
      filter = "bcm2835-rpi-zero-w.dtb";
      name = "bcm2835-rpi-zero-w.dtb";
    };
  };

  sdImage = {
    populateFirmwareCommands = ''
      (cd ${pkgs.raspberrypifw}/share/raspberrypi/boot && cp bootcode.bin fixup*.dat start*.elf $NIX_BUILD_TOP/firmware/)
      cp ${pkgs.raspberrypifw}/share/raspberrypi/boot/bcm2708-rpi-zero-w.dtb firmware/
      cp ${pkgs.ubootRaspberryPi}/u-boot.bin firmware/u-boot.bin
      cp ${configTxt} firmware/config.txt
      cp ${firmwareReadme} firmware/README.md
      mkdir -p firmware/wifi
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
