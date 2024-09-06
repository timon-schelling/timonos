{ config, ... }:

{
  programs.git = {
    enable = true;
    userName = config.opts.user.name;
    userEmail = config.opts.user.email;
  };
}
