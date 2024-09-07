{ lib, ... }: {
  opts = {
    system = {
      desktops.hyprland.enable = lib.mkDefault true;
    };
    users = {
      timon = {
        passwordHash = lib.mkDefault "$6$rounds=262144$btdA4Fl2MtXbCcEw$wzDDnSCaBlgUYNIXQm0fK8dKjHQAPFP6AiQz6qpZi3l9/h69WmbMAhSNtPYN5qSGcEw4yJGQT4W0KdPFvAcYg0";
        admin = lib.mkDefault true;
        home = {
          profile = lib.mkDefault "users.timon";
        };
      };
    };
  };
}
