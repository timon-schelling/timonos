{ ... }:

{
  programs.rio = {
    enable = true;
    settings = {
      cursor = "|";
      blinking-cursor = false;
      padding-x = 4;
      navigation.mode = "CollapsedTab";
      colors = {
        background = "#1c1c1c";
        foreground = "#aaaaaa";
        cursor = "#aaaaaa";
        selection-background = "#888888";
        selection-foreground = "#1c1c1c";

        #https://coolors.co/464646-dc4122-00df8a-ff9604-0068d0-c40089-00bdc4-727272
        black = "#464646";
        red = "#dc4122";
        green = "#00df8a";
        yellow = "#ff9604";
        blue = "#0068d0";
        magenta = "#c40089";
        cyan = "#00bdc4";
        white = "#727272";

        #https://coolors.co/272727-7e2514-00804f-945600-003c77-6e004d-006b6e-414141
        dim-black = "#272727";
        dim-red = "#7e2514";
        dim-green = "#00804f";
        dim-yellow = "#945600";
        dim-blue = "#003c77";
        dim-magenta = "#6e004d";
        dim-cyan = "#006b6e";
        dim-white = "#414141";

        #https://coolors.co/1c1c1c-e5715a-29ffad-ffb144-1d8eff-ff12b8-12f7ff-969696
        light-black = "#1c1c1c";
        light-red = "#e5715a";
        light-green = "#29ffad";
        light-yellow = "#ffb144";
        light-blue = "#1d8eff";
        light-magenta = "#ff12b8";
        light-cyan = "#12f7ff";
        light-white = "#969696";
      };
      fonts = {
        family = "JetBrainsMono Nerd Font";
        size = 24;
        extras = [
          { family = "Cascadia Mono"; }
        ];
        regular.weight = 600;
      };
      window.decorations = "Disabled";
    };
  };
}
