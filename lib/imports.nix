{ lib, ... }:

let
  collectModuleFile = type: dir:
    let
      path = (dir + "/${type}.nix");
    in
    if (builtins.pathExists path) then [ path ] else [];
  collectModulesSubDir = type: dir:
    lib.lists.flatten (
      lib.mapAttrsToList
        (file: kind:
          if kind == "directory" then
            collectModule type (dir + "/${file}")
          else []
        )
        (builtins.readDir dir)
    );
  collectModule = type: dir:
    (collectModuleFile type dir) ++ (collectModulesSubDir type dir);

  type = type: dir: collectModule type dir;
in
{
  inherit type;
}
