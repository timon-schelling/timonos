{ pkgs, ... }:

{
  fonts.fontconfig.enable = true;
  home.packages = with pkgs; [
    cascadia-code
    dejavu_fonts
    (nerdfonts.override { fonts = [
      "FiraCode"
      "FiraMono"
      "JetBrainsMono"
      "SourceCodePro"
      "Noto"
      "OpenDyslexic"
      "RobotoMono"
      "DejaVuSansMono"
      "NerdFontsSymbolsOnly"
    ];})
  ];
}
