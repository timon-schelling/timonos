{ pkgs, ... }:

{
  services = {
    pulseaudio.enable = false;
    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      jack.enable = true;
      extraLv2Packages = [
        pkgs.lsp-plugins
        pkgs.bankstown-lv2
        pkgs.rnnoise-plugin
      ];
      wireplumber.enable = true;
    };
  };
}
