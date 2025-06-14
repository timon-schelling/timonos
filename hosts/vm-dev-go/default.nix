{ lib, pkgs, config, ... }:

{
  imports = [
    ../vm-base
    ../vm-base-workspace
    ../vm-base-git
    ../vm-base-lang-go
  ];

  config = { };
}
