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
  buildProfileTree = list: lib.merge (lib.lists.map pathsToTree list);
  profiles = buildProfileTree profilePaths;

  mkProfileEnableOptionsRecursively =
    profiles:
    lib.mapAttrs (
      key: value:
      if value == { } then { enable = lib.mkEnableOption key; } else mkProfileEnableOptionsRecursively value
    ) profiles;
in
{
  options.opts.system = {
    profile = lib.mkOption {
      type = lib.types.enum (lib.lists.map (x: lib.strings.concatStringsSep "." x) profilePaths);
      default = "default";
    };
    profiles = mkProfileEnableOptionsRecursively profiles;
  };
  config = lib.mkMerge ((
    lib.lists.map (
      e: (lib.mkIf ((lib.attrsets.getAttrFromPath e.fst config.opts.system.profiles).enable) (import e.snd args))
    ) (lib.lists.zipLists profilePaths profileFiles)
  ) ++ [
    {
      opts.system.profiles = lib.attrsets.setAttrByPath (lib.strings.splitString "." config.opts.system.profile) { enable = true; };
    }
  ]);
}
