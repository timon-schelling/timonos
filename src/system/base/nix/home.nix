{ config, ... }:

{
  platform.user.persist.folders = [
    {
      directory = ".cache/nix";
      method = "symlink";
    }
  ];

  home.stateVersion = config.opts.system.stateVersion;
  xdg.configFile."nixpkgs/config.nix".text = ''
    {
      allowUnfree = true;
    }
  '';
  home.enableNixpkgsReleaseCheck = false;
}
