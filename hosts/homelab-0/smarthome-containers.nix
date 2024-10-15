# TODO: this should be properly done with a rootless podman setup with a homelab user

{ pkgs, lib, ... }:

let
  basename = "homelab";
  configDirInEtc = "${basename}";
  configDir = "/etc/${configDirInEtc}";
  dataDir = "/var/lib/${basename}";
  targetName = "homelab";
  domain = "home.timon.zip";
  backend = "podman";
  containers = {
    ddns = {
      image = "docker.io/joshava/cloudflare-ddns";
      environment = {
        "CRON" = "*/5 * * * *";
      };
      volumes = [
        "${dataDir}/ddns/data/config.yml:/app/config.yaml:rw"
      ];
      log-driver = "journald";
      extraOptions = [
        "--dns=1.1.1.1"
        "--network-alias=ddns"
      ];
    };
    traefik = {
      image = "docker.io/library/traefik";
      volumes = [
        "${dataDir}/traefik/data:/data:rw"
        (
          if (backend == "podman")
          then "/run/podman/podman.sock:/var/run/docker.sock:ro"
          else "/run/docker.sock:/var/run/docker.sock:ro"
        )
      ];
      ports = [
        "8080:8080/tcp"
        "80:80/tcp"
        "443:443/tcp"
      ];
      cmd = [
        "--log.level=DEBUG"
        "--providers.docker"
        "--providers.docker.exposedByDefault=false"
        "--api.dashboard=true"
        "--api.insecure=true"
        "--entrypoints.web.address=:80"
        "--entrypoints.websecure.address=:443"
        "--certificatesresolvers.main.acme.email=mail@timokrates.de"
        "--certificatesresolvers.main.acme.storage=/data/acme.json"
        "--certificatesresolvers.main.acme.httpchallenge=true"
        "--certificatesresolvers.main.acme.httpchallenge.entrypoint=web"
        "--entrypoints.web.http.redirections.entryPoint.to=websecure"
        "--entrypoints.web.http.redirections.entryPoint.scheme=https"
      ];
      log-driver = "journald";
      extraOptions = [
        "--add-host=host.docker.internal:172.17.0.1"
        "--network-alias=traefik"
      ];
    };
    hass = {
      image = "ghcr.io/home-assistant/home-assistant:2024.9";
      volumes = [
        "${dataDir}/hass/data:/config:rw"
        # "/etc/localtime:/etc/localtime:ro"
      ];
      labels = {
        "traefik.enable" = "true";
        "traefik.http.routers.hass.entrypoints" = "websecure";
        "traefik.http.routers.hass.rule" = "Host(`${domain}`)";
        "traefik.http.routers.hass.tls.certresolver" = "main";
        "traefik.http.services.hass.loadbalancer.server.port" = "8123";
      };
      log-driver = "journald";
      extraOptions = [
        "--network-alias=hass"
        "--privileged"
      ];
      ports = [
        "8081:8123/tcp"
      ];
    };
    mqtt = {
      image = "docker.io/library/eclipse-mosquitto:2.0.15";
      volumes = [
        "${configDir}/mqtt/config:/mosquitto/config/mosquitto.conf:ro"
        "${dataDir}/mqtt/log:/mosquitto/log:rw"
        "${dataDir}/mqtt/data:/mosquitto/data:rw"
      ];
      ports = [
        "1883:1883/tcp"
        "9001:9001/tcp"
      ];
      log-driver = "journald";
      extraOptions = [
        "--network-alias=mqtt"
      ];
    };
    zigbee2mqtt = {
      image = "ghcr.io/koenkk/zigbee2mqtt:1.40.1";
      environment = {
        "TZ" = "Europe/Berlin";
      };
      volumes = [
        # TODO: do this properly by copying the config file to the right place if it doesn't exist
        # this way the container writes to the nix store and that's really bad
        # "${configDir}/zigbee2mqtt/config.yaml:/app/data/configuration.yaml:ro"
        "${dataDir}/zigbee2mqtt/data/configuration.yaml:/app/data/configuration.yaml:rw"
        "${dataDir}/zigbee2mqtt/data/configuration.yaml:/app/configuration.yaml:rw"

        "${dataDir}/zigbee2mqtt/data:/app/data:rw"
        "/run/udev:/run/udev:ro"
      ];
      ports = [
        "8082:8080/tcp"
      ];
      dependsOn = [
        "mqtt"
      ];
      log-driver = "journald";
      extraOptions = [
        "--device=/dev/ttyUSB0:/dev/ttyUSB0"
        "--network-alias=zigbee2mqtt"
      ];
    };
  };
  dataDirs = [
    "${dataDir}/ddns/data"

    "${dataDir}/hass/data"

    "${dataDir}/mqtt/log"
    "${dataDir}/mqtt/data"

    "${dataDir}/traefik/data"

    "${dataDir}/zigbee2mqtt/data"
  ];
  zigbee2mqttConf = {
    homeassistant = true;
    permit_join = false;
    frontend = true;
    mqtt = {
      base_topic = "zigbee";
      server = "mqtt://mqtt";
    };
    serial = {
      port = "/dev/ttyUSB0";
    };
    advanced = {
      homeassistant_legacy_entity_attributes = false;
      legacy_api = false;
      legacy_availability_payload = false;
      log_syslog = {
        app_name = "Zigbee2MQTT";
        eol = "/n";
        host = "localhost";
        localhost = "localhost";
        path = "/dev/log";
        pid = "process.pid";
        port = 514;
        protocol = "udp4";
        type = "5424";
      };
      channel = 25;
      log_level = "info";
    };
    device_options = {
      legacy = false;
    };
    availability = {
      active = {
        timeout = 5;
      };
      passive = {
        timeout = 120;
      };
    };
  };
  mqttConf = ''
    listener 1883 0.0.0.0
    allow_anonymous true
    persistence true
    persistence_location /mosquitto/data/
    log_dest file /mosquitto/log/mosquitto.log
  '';
in
{

  opts.system.persist.folders = [
    "/var/lib/containers"
    dataDir
  ];

  virtualisation = lib.mkMerge [
    (lib.mkIf (backend == "podman") {
      podman = {
        enable = true;
        autoPrune.enable = true;
        dockerCompat = true;
        defaultNetwork.settings.dns_enabled = true;
      };
      oci-containers.backend = "podman";
    })
    ({
      oci-containers.containers = containers;
    })
  ];

  systemd.services = lib.mkMerge [
    (
      lib.mapAttrs'
      (n: v:
        lib.nameValuePair
          "${backend}-${n}"
          {
            serviceConfig = {
              Restart = lib.mkOverride 500 "always";
            };
            after = [
              "homelab-create-data-dirs.service"
            ];
            requires = [
              "homelab-create-data-dirs.service"
            ];
            partOf = [ "${targetName}.target" ];
            wantedBy = [ "${targetName}.target" ];
          }
      )
      containers
    )
    {
      "homelab-create-data-dirs" = {
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
        };
        script = ''
          ${(
            pkgs.nu.writeScript "homelab-create-data-dirs"
            (lib.concatStrings (lib.map (path: "mkdir ${path}\n") dataDirs))
          )}
        '';
        partOf = [ "${targetName}.target" ];
        wantedBy = ["${targetName}.target" ];
      };
    }
  ];

  systemd.targets."${targetName}" = {
    wantedBy = [ "multi-user.target" ];
  };

  environment.etc."${configDirInEtc}/zigbee2mqtt/config.yaml".source =
    (pkgs.formats.yaml { }).generate "zigbee2mqtt-config.yaml" zigbee2mqttConf;

  environment.etc."${configDirInEtc}/mqtt/config".text = mqttConf;
}
