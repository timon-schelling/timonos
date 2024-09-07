{ pkgs, ... }:

{
  home.pointerCursor = {
    gtk.enable = true;
    package = pkgs.oreo-cursors-plus.override {
      cursorsConf = ''
        custom = color: #1c1c1c, stroke: #eeeeee, stroke-width: 2, stroke-opacity: 1
        sizes = 22
      '';
    };
    name = "oreo_custom_cursors";
    size = 20;
  };
}
