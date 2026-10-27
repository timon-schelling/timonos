{ config, lib, ... }:

let
  mkStage = { name, description, prefix, tmpfiles, parent, entries }:
    let
      stage = { inherit prefix tmpfiles entries; target = "${name}.target"; };
    in
    {
      targets.${name} = {
        inherit description;
        before = [ parent ];
        wantedBy = [ parent ];
      };
      tmpfiles.settings.persist = mkTmpfiles stage;
      mounts = mkMounts stage;
    };

  mkTmpfiles = { prefix, entries, ... }: lib.mkMerge (lib.concatMap
    (e:
      let
        perms = { inherit (e) user group mode; };
        parentsOf = rel:
          let parts = lib.splitString "/" rel;
          in map (n: lib.concatStringsSep "/" (lib.take n parts)) (lib.range 1 (lib.length parts - 1));
        parent = path: { "${prefix}${path}".d = lib.mkDefault { inherit (e.owner) user group; }; };
        parents = lib.optionals (e.owner.user != "-")
          (lib.concatMap (p: [ (parent "${e.storage}/${p}") (parent "${e.base}/${p}") ]) (parentsOf e.rel));
      in
      parents ++ [
        (if e.kind == "dir" then {
          "${prefix}${e.persistent}".d = perms;
          "${prefix}${e.volatile}".d = perms;
        } else if e.method == "bind" then {
          "${prefix}${e.persistent}".f = perms;
          "${prefix}${e.volatile}".f = perms;
        } else parent (dirOf e.persistent) // {
          "${prefix}${e.volatile}".L.argument = e.persistent;
        })
      ])
    entries);

  mkMounts = { prefix, tmpfiles, target, entries }: map
    (e: {
      what = "${prefix}${e.persistent}";
      where = "${prefix}${e.volatile}";
      type = "none";
      options = lib.concatStringsSep "," ([ "bind" "x-gvfs-hide" ] ++ lib.optional e.initrd "x-initrd.mount");
      unitConfig = {
        DefaultDependencies = false;
      } // lib.optionalAttrs (e.kind == "file") {
        ConditionPathExists = "${prefix}${e.persistent}";
      };
      conflicts = [ "umount.target" ];
      wantedBy = [ target ];
      before = [ target ] ++ lib.optional (e.kind == "dir") tmpfiles;
      after = lib.optional (e.kind == "file") tmpfiles;
    })
    (lib.filter (e: e.method == "bind") entries);

  mkEntries = { storage, base, owner, method }: persists:
    let
      mkEntry = kind: entry:
        let
          e = if lib.isString entry then { ${if kind == "dir" then "directory" else "file"} = entry; } else entry;
          rel = lib.removeSuffix "/" (lib.removePrefix "/" (e.directory or e.file));
        in
        {
          inherit kind storage base owner rel;
          volatile = "${base}/${rel}";
          persistent = "${storage}/${rel}";
          user = e.user or owner.user;
          group = e.group or owner.group;
          mode = e.mode or "-";
          method = if kind == "dir" then "bind" else e.method or method;
          initrd = e.initrd or false;
        };
    in
    lib.concatMap (p: map (mkEntry "dir") p.folders ++ map (mkEntry "file") p.files) persists;


  users = lib.mapAttrs
    (name: home: {
      inherit name home;
      inherit (config.users.users.${name}) group;
      root = "/persist/user/${name}";
      dir = config.users.users.${name}.home;
    })
    config.home-manager.users;

  entries =
    let
      systemEntries = mkEntries
        {
          storage = "/persist/system";
          base = "";
          owner = { user = "-"; group = "-"; };
          method = "bind";
        }
        [ config.platform.system.persist config.opts.system.persist ];
      userEntries = lib.concatMap
        (user:
          let
            location = storage: {
              inherit storage;
              base = user.dir;
              owner = { user = user.name; inherit (user) group; };
              method = "symlink";
            };
            inherit (user.home.opts.user) persist;
          in
          mkEntries (location "${user.root}/data") [ persist.data ]
          ++ mkEntries (location "${user.root}/state") [ user.home.platform.user.persist persist.state ])
        (lib.attrValues users);
    in
    systemEntries ++ userEntries;
in
{
  config = lib.mkIf config.platform.system.filesystem.persist.enable {
    fileSystems."/persist".neededForBoot = true;

    assertions = lib.concatMap
      (e: [
        {
          assertion = !e.initrd || (lib.elem e.user [ "-" "root" ] && lib.elem e.group [ "-" "root" ]);
          message = "${e.volatile} in initrd must be owned by root";
        }
        {
          assertion = lib.count (o: o.volatile == e.volatile) entries == 1;
          message = "${e.volatile} is persisted more than once";
        }
      ])
      entries;

    boot.initrd.systemd = mkStage {
      name = "initrd-persist";
      description = "Persistent Storage Mounts (initrd)";
      prefix = "/sysroot";
      tmpfiles = "systemd-tmpfiles-setup-sysroot.service";
      parent = "initrd.target";
      entries = lib.filter (e: e.initrd) entries;
    };

    systemd = lib.mkMerge [
      (mkStage {
        name = "persist";
        description = "Persistent Storage Mounts";
        prefix = "";
        tmpfiles = "systemd-tmpfiles-setup.service";
        parent = "sysinit.target";
        entries = lib.filter (e: !e.initrd) entries;
      })
      {
        tmpfiles.settings.persist = lib.mkMerge ([
          {
            "/persist/system".d = { user = "root"; group = "root"; mode = "0755"; };
            "/persist/user".d = { user = "root"; group = "root"; mode = "0755"; };
          }
        ] ++ lib.mapAttrsToList
          (_: user: lib.genAttrs [ user.root "${user.root}/data" "${user.root}/state" ]
            (_: { d = { user = user.name; inherit (user) group; mode = "0700"; }; }))
          users);
      }
    ];
  };
}
