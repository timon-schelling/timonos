{ config, inputs, pkgs, lib, ... }:

{
  imports = [
    inputs.impermanence.nixosModules.impermanence
  ];

  config = lib.mkIf config.platform.system.filesystem.persist.enable {
    fileSystems."/persist".neededForBoot = true;
    environment.persistence."/persist/system" = {
      hideMounts = true;
      directories = config.platform.system.persist.folders ++ config.opts.system.persist.folders;
      files = config.platform.system.persist.files ++ config.opts.system.persist.files;
    };

    systemd.services."create-persist-user-dir" = {
      description = "Create /persist/user directory for Home Manager Impermanence with 1700 permissions";
      requiredBy = [ "multi-user.target" ];
      after = [ "basic.target" ];
      before = [ "graphical-session-pre.target" ];
      script = ''
        ${pkgs.coreutils}/bin/mkdir -p /persist/user
        ${pkgs.coreutils}/bin/chmod 755 /persist/user
      '' + lib.concatStrings (lib.mapAttrsToList
        (name: user: ''
          # Create user persist directory for user `${name}`
          ${pkgs.coreutils}/bin/mkdir -p /persist/user/${name}
          ${pkgs.coreutils}/bin/chmod 700 /persist/user/${name}
          ${pkgs.coreutils}/bin/chown ${name}:users /persist/user/${name}
        '')
        config.opts.users
      );
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        User = "root";
        Group = "root";
      };
    };

    programs.fuse.userAllowOther = true;
  };
}
