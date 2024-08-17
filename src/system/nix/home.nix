{ config, ... }:

{
  home.stateVersion = config.opts.system.stateVersion;
  xdg.configFile."nixpkgs/config.nix".text = ''
    {
      allowUnfree = true;
    }
  '';
}
