{ pkgs, ... }:

{
  opts.system = {
    profile = "users.timon";
    drive = "/dev/nvme1n1";
    hardware.gpu.nvidia.monitorDdcciFixEnable = true;
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

  # disable the tpm module because is not supported and causes failures during boot
  boot.blacklistedKernelModules = [ "tpm" "tpm_atmel" "tpm_infineon" "tpm_nsc" "tpm_tis" "tpm_crb" ];

  # steam
  hardware.graphics.enable32Bit = true;
  opts.users.timon.home.persist.state.folders = [ ".local/share/Steam" ];
  home-manager.users.timon.home.packages = [ pkgs.steam ];
  # for unity games set data folder with `XDG_CONFIG_HOME=~/.local/share/Steam/data %command%` in steam launch options
}
