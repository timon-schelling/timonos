{ config, ... }:

{
  platform.user.persist.folders = [
    ".cache/nix"
  ];

  home.stateVersion = config.opts.system.stateVersion;
  xdg.configFile."nixpkgs/config.nix".text = ''
    {
      allowUnfree = true;
    }
  '';
  home.enableNixpkgsReleaseCheck = false;
}
