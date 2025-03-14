{ pkgs, ... }:

{
  programs.ghostty = {
    enable = true;
    settings = {
      font-family = "JetBrainsMono NF SemiBold";
      font-size = 15;
      theme = "0x0";
      cursor-style = "bar";
      adjust-cursor-thickness = 2;
      cursor-style-blink = false;
      scrollback-limit = 10000;
      window-padding-x = 5;
      window-padding-y = 3;
      font-synthetic-style = "bold";
      resize-overlay = "never";
      window-theme = "ghostty";
      adw-toolbar-style = "flat";
      gtk-single-instance = true;
      keybind = [
        "ctrl+t=new_tab"
        "ctrl+w=close_surface"
        "alt+down=jump_to_prompt:1"
        "alt+up=jump_to_prompt:-1"
        "ctrl+shift+s=copy_to_clipboard"
        "ctrl+s=paste_from_clipboard"
        "ctrl+shift+down=write_scrollback_file:paste"
        "ctrl+shift+up=reset"
      ];
    };
    themes."0x0" = {
      cursor-color = "aaaaaa";
      background = "1c1c1c";
      foreground = "aaaaaa";
      selection-background = "888888";
      selection-foreground = "1c1c1c";
      palette = [
        "0=#464646"
        "1=#dc4122"
        "2=#00df8a"
        "3=#ff9604"
        "4=#0068d0"
        "5=#c40089"
        "6=#00bdc4"
        "7=#969696"
        "8=#1c1c1c"
        "9=#e5715a"
        "10=#29ffad"
        "11=#ffb144"
        "12=#1d8eff"
        "13=#ff12b8"
        "14=#12f7ff"
        "15=#969696"
      ];
    };
    package = (pkgs.runCommand "ghostty-custom"
      {
        buildInputs = [ pkgs.makeWrapper ];
        meta.mainProgram = pkgs.ghostty.meta.mainProgram;
      }
      ''
        makeWrapper ${pkgs.ghostty}/bin/ghostty $out/bin/ghostty --unset GTK_THEME
        cp -r "${pkgs.ghostty}/share" "$out/"
      ''
    );
  };
}
