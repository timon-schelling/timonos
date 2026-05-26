{ lib, pkgs, config, ... }:

{
  imports = [
    ../vm-base
    ../vm-base-workspace
    ../vm-base-vcs
    ../vm-base-persist
    ../vm-base-docker
    ../vm-base-ai-tools
  ];

  config = {
    environment.systemPackages = with pkgs; [
      nodejs
    ];
  };
}
