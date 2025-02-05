{ config, inputs, lib, ... }:

{
  imports = [
    inputs.impermanence.nixosModules.home-manager.impermanence
  ];
  config = lib.mkIf (config.opts.system.filesystem.type == "impermanent") {
    home.persistence."/persist/user/${config.opts.username}/data" = {
      directories = config.opts.user.persist.data.folders;
      files = config.opts.user.persist.data.files;
      allowOther = true;
    };
    home.persistence."/persist/user/${config.opts.username}/state" = {
      directories = config.platform.user.persist.folders ++ config.opts.user.persist.state.folders;
      files = config.platform.user.persist.files ++ config.opts.user.persist.state.files;
      allowOther = true;
    };
  };
}
