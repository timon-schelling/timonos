{ pkgs, ... }:

{
  home.pointerCursor = {
    enable = true;
    gtk.enable = true;
    package = pkgs.oreo-custom-cursors;
    name = "oreo_custom_cursors";
    size = 24;
  };
}
