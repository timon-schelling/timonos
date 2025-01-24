{ pkgs, config, lib, ... }:

{
  platform.user.persist.folders = [
    ".cache/com.github.neithern.g4music"
  ];

  home.packages = [
    pkgs.gapless
  ];

  dconf.settings = {
    "com/github/neithern/g4music" = {
      blur-mode = (lib.hm.gvariant.mkUint32 0);
      gapless-playback = true;
      music-dir = "file://${config.home.homeDirectory}/media/music";
      peak-characters = "_";
      replay-gain = (lib.hm.gvariant.mkUint32 1);
      rotate-cover = false;
      show-peak = true;
      sort-mode = (lib.hm.gvariant.mkUint32 5);
    };
  };
}
