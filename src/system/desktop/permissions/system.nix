{ ... }:

{
  security.polkit = {
    enable = true;
    adminIdentities = [ "unix-group:admin" ];
    enablePkexecWrapper = true;
  };
}
