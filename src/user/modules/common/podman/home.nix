{ config, lib, pkgs, ... }:

let
  cfg = config.opts.user.podman;
in
{
  options = {
    opts.user.podman.enable = lib.mkEnableOption "podman user mode";
  };
  config = lib.mkIf cfg.enable {
    platform.user.persist.folders = [
      {
        directory = ".local/share/containers/storage";
        method = "symlink";
      }
    ];

    home.packages = [
      pkgs.podman
      pkgs.podman-compose
    ];

    xdg.configFile = (
      let
        mkToml = (pkgs.formats.toml { }).generate;
      in
      {
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
      }
    );
  };
}
