{ ... }:

{
  systemd.user.settings.Manager = {
    DefaultLimitNOFILE = 1048576;
  };
}
