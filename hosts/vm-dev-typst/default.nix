{ lib, pkgs, config, ... }:

{
  imports = [
    ../vm-base
    ../vm-base-workspace
    ../vm-base-lang-typst
  ];

  config = { };
}
