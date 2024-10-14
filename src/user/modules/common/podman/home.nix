{ config, lib, pkgs, ... }:

let
  cfg = config.opts.user.podman;
  mkToml = (pkgs.formats.toml { }).generate;
in
{
  options = {
    opts.user.podman.enable = lib.mkEnableOption "Enable podman user mode";
  };
  config = lib.mkIf cfg.enable {
    platform.user.persist.folders = [
      {
        directory = ".local/share/containers/storage";
        method = "symlink";
      }
    ];

    xdg.configFile = {
      "containers/policy.json".source = "${pkgs.skopeo.src}/default-policy.json";
      "containers/registries.conf".source = mkToml "registries.conf" {
        registries.search.registries = [ "docker.io" ];
      };
      "containers/storage.conf".source = mkToml "storage.conf" {
        storage = {
          driver = "overlay";
          options.mount_program = lib.getExe pkgs.fuse-overlayfs;
        };
      };
    };

    home.packages = [
      pkgs.podman
      pkgs.podman-compose
    ];
  };
}
