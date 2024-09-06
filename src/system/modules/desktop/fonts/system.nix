{ pkgs, ... }:

{
  # TODO: remove once https://github.com/NixOS/nixpkgs/pull/338328 (9729387a99fcff79e06dfd631f74a2923a84d585) gets to nixpkgs-unstable
  imports = [ ./fix-nixpkgs-338328.nix ];

  fonts = {
    fontconfig.enable = true;
    packages = with pkgs; [
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
  };
}
