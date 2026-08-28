{ ... }:

{
  security.polkit.enable = true;
  security.polkit.adminIdentities = [ "unix-group:admin" ];
}
