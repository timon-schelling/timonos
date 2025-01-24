{ pkgs, config, ... }:

{
  platform.user.persist.folders = [
    ".cache/com.github.neithern.g4music"
  ];

  home.packages = [
    pkgs.gapless
  ];

  dconf.settings = {
    "com/github/neithern/g4music" = {
      blur-mode = 0;
      gapless-playback = true;
      music-dir = "file://${config.home.homeDirectory}/media/music";
      peak-characters = "_";
      replay-gain = 1;
      rotate-cover = false;
      show-peak = true;
      sort-mode = 5;
    };
  };
}
