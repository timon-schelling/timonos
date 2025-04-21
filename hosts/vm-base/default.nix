{ lib, pkgs, config, ... }:

let
  conf = {
    initrd_path = "${config.system.build.initialRamdisk}/${config.system.boot.loader.initrdFile}";
    kernel_path = "${pkgs.contain-default-kernel}";
    cmdline = "console=hvc0 loglevel=4 reboot=t panic=-1 lsm=on root=fstab init=${config.system.build.toplevel}/init regInfo=${pkgs.closureInfo {rootPaths = [ config.system.build.toplevel ];}}/registration";
    cpu = {
      cores = 16;
    };
    memory = {
      size = 16384;
    };
    filesystem = {
      shares = [
        {
          tag = "nix-store-ro";
          source = "/nix/store";
          write = false;
        }
      ];
    };
    network = {
      assign_tap_device = true;
    };
    graphics = {
      virtio_gpu = true;
    };
    console = {
      mode = "on";
    };
  };
  json = pkgs.formats.json {};
in
{
  options.contain = {

    config = lib.mkOption {
      type = json.type;
      default = conf;
    };

    configFile = lib.mkOption (
      let
        recursiveMergeImpl = with lib; args:
          zipAttrsWith (n: values:
            if tail values == []
              then head values
            else if all isList values
              then unique (concatLists values)
            else if all isAttrs values
              then recursiveMergeImpl (args ++ [n]) values
            else last values
          );
        recursiveMerge = args: recursiveMergeImpl [] args;
      in
      {
        type = lib.types.path;
        default = json.generate "contain-config.json" (recursiveMerge [conf config.contain.config]);
      }
    );
  };

  config = {

    systemd.services."systemd-vconsole-setup".enable = false;

    boot.postBootCommands = ''
      if [[ "$(cat /proc/cmdline)" =~ regInfo=([^ ]*) ]]; then
        ${config.nix.package.out}/bin/nix-store --load-db < ''${BASH_REMATCH[1]}
      fi
    '';
    systemd.sockets.nix-daemon.enable = lib.mkDefault true;
    systemd.services.nix-daemon.enable = lib.mkDefault true;

    systemd.services.mount-pstore.enable = false;
    systemd.services.logrotate-checkconf.enable = false;
    systemd.network.wait-online.enable = lib.mkDefault false;
    networking.firewall.enable = false;
    documentation.enable = lib.mkDefault false;
    systemd.services.systemd-journal-flush.enable = false;
    systemd.services.kmod-static-nodes.enable = false;
    systemd.services.systemd-journal-catalog-update.enable = false;
    systemd.sockets.systemd-journald-audit.enable = false;
    systemd.sockets.systemd-journald-dev-log.enable = false;
    systemd.services.systemd-logind.serviceConfig = {
      StandardOutput = "null";
      StandardError = "null";
    };
    console.earlySetup = false;
    services.logrotate.enable = false;

    fileSystems = {
      "/" = {
        device = "rootfs";
        fsType = "tmpfs";
        mountPoint = "/";
        neededForBoot = true;
        options = [
          "x-initrd.mount"
          "size=50%,mode=0755"
        ];
      };
      "/nix/.ro-store" = {
        device = lib.mkForce "nix-store-ro";
        fsType = lib.mkForce "virtiofs";
        mountPoint = lib.mkForce "/nix/.ro-store";
        neededForBoot = lib.mkForce true;
        options = lib.mkForce [
          "x-initrd.mount"
          "defaults"
          "x-systemd.requires=systemd-modules-load.service"
        ];
      };
      "/nix/store" = {
        depends = [
          "/nix/.ro-store"
          "/nix/.rw-store"
        ];
        device = lib.mkForce "overlay";
        fsType = lib.mkForce "overlay";
        mountPoint = lib.mkForce "/nix/store";
        neededForBoot = lib.mkForce true;
        options = lib.mkForce [
          "x-initrd.mount"
          "x-systemd.requires-mounts-for=/sysroot/nix/.ro-store"
          "x-systemd.requires-mounts-for=/sysroot/nix/.rw-store"
          "lowerdir=/nix/.ro-store"
          "upperdir=/nix/.rw-store/store"
          "workdir=/nix/.rw-store/work"
        ];
      };
    };

    boot.kernel.sysctl."net.ipv4.ip_unprivileged_port_start" = lib.mkDefault 64;

    # needed to boot with contain default kernel
    nixpkgs.overlays = [
      (self: super: {
        makeModulesClosure = {...}: (
          super.runCommand "makeModulesClosureMock" {} ''
            mkdir -p $out/lib
          ''
        );
      })
    ];

    # boot.initrd.systemd patchups copied from <nixpkgs/nixos/modules/virtualisation/qemu-vm.nix>
    boot.initrd.systemd =
    let
      writableStoreOverlay = "/nix/.rw-store";
      roStore = "/nix/.ro-store";
    in
    {
      services.systemd-vconsole-setup.enable = false;
      services.systemd-journald.enable = false;
      services.systemd-journal-flush.enable = false;
      sockets.systemd-journald-audit.enable = false;

      emergencyAccess = true;
      mounts = [ {
        where = "/sysroot/nix/store";
        what = "overlay";
        type = "overlay";
        options = builtins.concatStringsSep "," [
          "lowerdir=/sysroot${roStore}"
          "upperdir=/sysroot${writableStoreOverlay}/store"
          "workdir=/sysroot${writableStoreOverlay}/work"
        ];
        wantedBy = [ "initrd-fs.target" ];
        before = [ "initrd-fs.target" ];
        requires = [ "rw-store.service" ];
        after = [ "rw-store.service" ];
        unitConfig.RequiresMountsFor = "/sysroot/${roStore}";
      } ];
      services.rw-store = {
        unitConfig = {
          DefaultDependencies = false;
          RequiresMountsFor = "/sysroot${writableStoreOverlay}";
        };
        serviceConfig = {
          Type = "oneshot";
          ExecStart = "/bin/mkdir -p -m 0755 /sysroot${writableStoreOverlay}/store /sysroot${writableStoreOverlay}/work /sysroot/nix/store";
        };
      };

      tpm2.enable = false;
    };

    # Fix for hanging shutdown
    systemd.mounts = lib.mkIf config.boot.initrd.systemd.enable [ {
      what = "store";
      where = "/nix/store";
      overrideStrategy = "asDropin";
      unitConfig.DefaultDependencies = false;
    } ];

    environment.sessionVariables = {
      WAYLAND_DISPLAY = "wayland-1";
      DISPLAY = ":0";
      GDK_BACKEND = "wayland";
      XDG_SESSION_TYPE = "wayland";
      SDL_VIDEODRIVER = "wayland";
      CLUTTER_BACKEND = "wayland";
    };

    systemd.user.services = {
      wayland-proxy = {
        enable = true;
        description = "wayland proxy";
        serviceConfig = {
          ExecStart = "${pkgs.wayland-proxy-virtwl}/bin/wayland-proxy-virtwl --virtio-gpu --tag='[vm] - ' --x-display=0 --xwayland-binary=${pkgs.xwayland}/bin/Xwayland";
          Restart = "on-failure";
          RestartSec = 5;
        };
        wantedBy = [ "default.target" ];
      };
    };

    environment.systemPackages = [
      (pkgs.nu.writeScriptBin "run-wayland-proxy" ''
        def --wrapped main [...args] {
          ${pkgs.wayland-proxy-virtwl}/bin/wayland-proxy-virtwl ---virtio-gpu -- ...$args
        }
      '')
      (pkgs.nu.writeScriptBin "ip" ''
        def --wrapped main [...args] {
            if ($args | length) > 0 {
                ${pkgs.iproute2}/bin/ip ...$args
            } else {
                ${pkgs.iproute2}/bin/ip --json addr show dev main | from json | get addr_info.0 | filter { $in.family == "inet6" } | get local.0 | echo $"[($in)]" | wl-copy
            }
        }
      '')
      pkgs.daemonize
    ];

    home-manager.users.user.programs.nushell.extraConfig = lib.mkAfter ''
      alias stop = poweroff
      alias s = stop

      def --wrapped daemon [...args] {
        job spawn { run-external ...$args }
      }
      alias d = daemon

      alias j = daemon ghostty --working-directory=$"\(pwd)"\""
      alias n = daemon rio --working-dir $"\(pwd)"\""
      alias h = daemon code .
      alias k = daemon firefox
      alias l = daemon nautilus .
    '';

    home-manager.users.user.programs.starship.settings.format = lib.mkForce ''
      vm $username $directory ($git_branch$git_status$git_state)
      $character
    '';

    home-manager.users.user.programs.vscode.profiles.default.userSettings.security.workspace.trust.enabled = false;

    opts = {
      system = {
        filesystem.type = "none";
        adminAllowNoPassword = true;
        login.auto = {
          enable = true;
          user = "user";
        };
        desktops.guest.enable = true;
      };
      users = {
        user = {
          admin = true;
          home = {
            desktops.guest.default.enable = true;
            apps = {
              terminal = {
                rio.enable = true;
                ghostty.enable = true;
              };
              editor = {
                vscode.enable = true;
                lapce.enable = true;
              };
              browser = {
                firefox.enable = true;
                chromium.enable = true;
                tor-browser.enable = true;
              };
              filemanager = {
                nautilus.enable = true;
              };
              utils = {
                btop.enable = true;
              };
              passwordmanager = {
                enpass.enable = true;
              };
            };
            git.enable = true;
          };
        };
      };
    };
  };
}
