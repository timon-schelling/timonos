{ config, lib, pkgs, ... } @args:

let
  appsFolder = ./.;
  appFiles = lib.imports.type "app" appsFolder;
  appPaths = lib.map (
    path:
    lib.lists.init (
      lib.strings.splitString "/" (lib.strings.removePrefix "./" (lib.path.removePrefix appsFolder path))
    )
  ) appFiles;
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
  buildAppTree = list: lib.merge (lib.lists.map pathsToTree list);
  apps = buildAppTree appPaths;

  mkAppEnableOptionsRecursively =
    apps:
    lib.mapAttrs (
      key: value:
      if value == { } then { enable = lib.mkEnableOption key; } else mkAppEnableOptionsRecursively value
    ) apps;
in
{
  options.opts.user.apps = mkAppEnableOptionsRecursively apps;
  config = lib.mkMerge (
    lib.lists.map (
      e: (lib.mkIf ((lib.attrsets.getAttrFromPath e.fst config.opts.user.apps).enable) (import e.snd args))
    ) (lib.lists.zipLists appPaths appFiles)
  );
}
