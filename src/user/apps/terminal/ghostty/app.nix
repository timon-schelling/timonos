{ ... }:

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
      window-padding-x = [5 5];
      window-padding-y = [3 3];
      font-synthetic-style = "bold";
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
  };
}
