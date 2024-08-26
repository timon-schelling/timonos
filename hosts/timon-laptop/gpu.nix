{ lib, pkgs, config, ... }:

let
  cfg = config.opts.system.hardware.gpu.nvidia.mobile.mode;
in
{
  options = {
    opts.system.hardware.gpu.nvidia.mobile.mode = lib.mkOption {
      type = lib.types.enum [ "hybrid" "integrated" ];
      default = "integrated";
    };
  };
  config = lib.mkMerge [
    (lib.mkIf (cfg == "hybrid") {
      hardware = {
        nvidia.prime = {
          offload = {
            enable = true;
            enableOffloadCmd = lib.mkForce true;
          };
          nvidiaBusId = "PCI:1:0:0";
          intelBusId = "PCI:0:2:0";
        };
      };
    })
    (lib.mkIf (cfg == "integrated") {
      # boot.extraModprobeConfig = ''
      #   blacklist nouveau
      #   options nouveau modeset=0
      # '';
      services.udev.extraRules = ''
        # Remove NVIDIA devices
        ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x0c0330", ATTR{power/control}="auto", ATTR{remove}="1"
        ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x0c8000", ATTR{power/control}="auto", ATTR{remove}="1"
        ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x040300", ATTR{power/control}="auto", ATTR{remove}="1"
        ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x03[0-9]*", ATTR{power/control}="auto", ATTR{remove}="1"
      '';
      boot.blacklistedKernelModules = [ "nouveau" "nvidia" "nvidia_drm" "nvidia_modeset" ];
    })
    (lib.mkIf (cfg == "hybrid" || cfg == "integrated") {
      hardware.graphics = {
        enable = true;
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
    })
  ];
}
