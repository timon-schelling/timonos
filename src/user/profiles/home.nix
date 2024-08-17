{ config, lib, pkgs, ... } @args:

let
  profilesFolder = ./.;
  profileFiles = lib.imports.type "profile" profilesFolder;
  profilePaths = lib.map (
    path:
    lib.lists.init (
      lib.strings.splitString "/" (lib.strings.removePrefix "./" (lib.path.removePrefix profilesFolder path))
    )
  ) profileFiles;
  pathsToTree =
    list:
    (
      let
        first = lib.head list;
        tail = lib.tail list;
      in
      {
        "${first}" = if tail != [ ] then (pathsToTree tail) else { };
      }
    );
  buildprofileTree = list: lib.merge (lib.lists.map pathsToTree list);
  profiles = buildprofileTree profilePaths;

  mkprofileEnableOptionsRecursively =
    profiles:
    lib.mapAttrs (
      key: value:
      if value == { } then { enable = lib.mkEnableOption key; } else mkprofileEnableOptionsRecursively value
    ) profiles;
in
{
  options.opts.user = {
    profile = lib.mkOption {
      type = lib.types.enum (lib.lists.map (x: lib.strings.concatStringsSep "." x) profilePaths);
      default = "default";
    };
    profiles = mkprofileEnableOptionsRecursively profiles;
  };
  config = lib.mkMerge ((
    lib.lists.map (
      e: (lib.mkIf ((lib.attrsets.getAttrFromPath e.fst config.opts.user.profiles).enable) (import e.snd args))
    ) (lib.lists.zipLists profilePaths profileFiles)
  ) ++ [
    {
      opts.user.profiles = lib.attrsets.setAttrByPath (lib.strings.splitString "." config.opts.user.profile) { enable = true; };
    }
  ]);
}
