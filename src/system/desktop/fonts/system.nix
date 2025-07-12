{ pkgs, ... }:

{
  fonts = {
    fontconfig.enable = true;
    packages = with pkgs; [
      cascadia-code
      dejavu_fonts
      font-metropolis

      nerd-fonts."fira-code"
      nerd-fonts."fira-mono"
      nerd-fonts."jetbrains-mono"
      nerd-fonts."noto"
      nerd-fonts."open-dyslexic"
      nerd-fonts."roboto-mono"
      nerd-fonts."dejavu-sans-mono"
      nerd-fonts."symbols-only"
    ];
  };
}
