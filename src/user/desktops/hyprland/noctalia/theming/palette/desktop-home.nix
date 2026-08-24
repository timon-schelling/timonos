{ pkgs, ... }:

let
  name = "custom";

  palette = {
    # The dark tones step 161616 -> 1e1e1e -> 292929 -> 3d3d3d -> 444444. The
    # shell now sits on 161616, the same background hyprland paints (T.background
    # in hyprland/lua/theme.lua), and every other dark tone moved down one step
    # onto it. The light foreground tones are untouched, so contrast only grows.
    dark = {
      mPrimary = "#aaaaaa";
      mOnPrimary = "#161616";
      mSecondary = "#999999";
      mOnSecondary = "#161616";
      mTertiary = "#878787";
      mOnTertiary = "#161616";
      mError = "#7e0000";
      mOnError = "#ffffff";

      mSurface = "#161616";
      mOnSurface = "#aaaaaa";
      mSurfaceVariant = "#1e1e1e";
      mOnSurfaceVariant = "#878787";
      mOutline = "#3d3d3d";
      mShadow = "#000000";
      mHover = "#292929";
      mOnHover = "#aaaaaa";

      terminal = terminal;
    };

    light = {
      mPrimary = "#3d3d3d";
      mOnPrimary = "#e1e1e1";
      mSecondary = "#4a4a4a";
      mOnSecondary = "#e1e1e1";
      mTertiary = "#555555";
      mOnTertiary = "#e1e1e1";
      mError = "#b02525";
      mOnError = "#ffffff";

      mSurface = "#e1e1e1";
      mOnSurface = "#1e1e1e";
      mSurfaceVariant = "#d6d6d6";
      mOnSurfaceVariant = "#3d3d3d";
      mOutline = "#878787";
      mShadow = "#000000";
      mHover = "#c2c2c2";
      mOnHover = "#1e1e1e";

      terminal = terminal;
    };
  };

  terminal = {
    background = "#1c1c1c";
    foreground = "#aaaaaa";
    cursor = "#aaaaaa";
    cursorText = "#1c1c1c";
    selectionBg = "#888888";
    selectionFg = "#1c1c1c";
    normal = {
      black = "#464646";
      red = "#dc4122";
      green = "#00df8a";
      yellow = "#ff9604";
      blue = "#0068d0";
      magenta = "#c40089";
      cyan = "#00bdc4";
      white = "#969696";
    };
    bright = {
      black = "#565656";
      red = "#e5715a";
      green = "#29ffad";
      yellow = "#ffb144";
      blue = "#1d8eff";
      magenta = "#ff12b8";
      cyan = "#12f7ff";
      white = "#969696";
    };
  };
in
{
  xdg.configFile."noctalia/palettes/${name}.json".source =
    (pkgs.formats.json { }).generate "noctalia-palette-${name}.json" palette;
}
