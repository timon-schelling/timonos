{ lib, pkgs, ... }:

{
  opts = {
    system = {
      drive = "/dev/nvme0n1";
      platform = "x86_64-linux";
    };
    users = {
      timon = {
        passwordHash = "$6$rounds=262144$btdA4Fl2MtXbCcEw$wzDDnSCaBlgUYNIXQm0fK8dKjHQAPFP6AiQz6qpZi3l9/h69WmbMAhSNtPYN5qSGcEw4yJGQT4W0KdPFvAcYg0";
        admin = true;
        home = {
          name = "Timon Schelling";
          email = "me@timon.zip";
          persist.data.folders = [
            "code"
            "data"
            "media"
            "tmp"
          ];
          profile = "personal";
        };
      };
    };
  };

  boot = {
    initrd = {
      availableKernelModules = [ "nvme" "xhci_pci" "usbhid" "thunderbolt" ];
      kernelModules = [ "dm-snapshot" ];
    };
    kernelModules = [ "kvm-intel" ];
  };

  hardware = {
    enableRedistributableFirmware = true;
    cpu.intel.updateMicrocode = true;
    graphics = {
      package = lib.mkForce (pkgs.mesa.override {
        galliumDrivers = [
          "nouveau"
          "swrast"
          "iris"
          "zink"
        ];
      }).drivers;
      extraPackages = with pkgs; [
        intel-media-driver
        intel-vaapi-driver
      ];
      extraPackages32 = with pkgs.driversi686Linux; [
        intel-media-driver
        intel-vaapi-driver
      ];
      enable32Bit = true;
    };
    nvidia.prime = {
      offload = {
        enable = true;
        enableOffloadCmd = lib.mkForce true;
      };
      nvidiaBusId = "PCI:1:0:0";
      intelBusId = "PCI:0:2:0";
    };
  };
}
