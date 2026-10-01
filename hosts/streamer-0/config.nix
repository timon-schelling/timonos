{ lib, pkgs, ... }:

{
  imports = [
    ./hardware.nix
    ./dac.nix
    ./audio.nix
    ./spotify.nix
    ./airplay.nix
    ./provision.nix
    ./vm.nix
  ];

  opts.system = {
    platform = "armv6l-linux";
    filesystem.type = "none";
    network = {
      wifi.enable = true;
      tailscale.enable = true;
    };
    login.greeter = "none";
    nix.nh.enable = false;
  };

  users.users.user = {
    isNormalUser = true;
    hashedPassword = "$6$rounds=262144$btdA4Fl2MtXbCcEw$wzDDnSCaBlgUYNIXQm0fK8dKjHQAPFP6AiQz6qpZi3l9/h69WmbMAhSNtPYN5qSGcEw4yJGQT4W0KdPFvAcYg0";
    shell = pkgs.bashInteractive;
    extraGroups = [
      "admin"
      "wifi"
      "pipewire"
    ];
  };

  nix.settings.trusted-users = [ "@admin" ];

  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = true;
      PermitRootLogin = "no";
    };
  };

  services.avahi.publish = {
    enable = true;
    addresses = true;
  };

  powerManagement.cpuFreqGovernor = "performance";

  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="net", KERNEL=="wlan0", RUN+="${pkgs.iw}/bin/iw dev wlan0 set power_save off"
  '';

  zramSwap = {
    enable = true;
    memoryPercent = 50;
  };

  environment.systemPackages = with pkgs; [
    i2c-tools
    libgpiod
    iw
    usbutils
  ];
}
