{ pkgs, lib, config, ... }:

let
  callServicePkgName = "monitor-fix-ddcci-nvidia";
  serviceName = "zip.timon.os.System.NvidiaDdcciMonitorFix";
  methodName = "fix";
  systemdServiceName = "nvidia-ddcci-monitor-fix";
  systemdUnitName = "${systemdServiceName}.service";
  serviceStartPkg = pkgs.nu.writeScript systemdServiceName ''
    $env.DBUS_SYSTEM_BUS_ADDRESS = "unix:path=/run/dbus/system_bus_socket"
    ${pkgs.dbus-listen}/bin/dbus-listen --system --interface ${serviceName} --member ${methodName} ${scriptPkg}
  '';
  scriptPkg = pkgs.nu.writeScript "ddcci-load-i2c-devices" ''
    if ('/tmp/ddcci-load-i2c-devices.lock' | path exists) {
        print "Already running"
        exit 0
    }

    $nu.pid | save /tmp/ddcci-load-i2c-devices.lock

    if ((open /tmp/ddcci-load-i2c-devices.lock | into int) == $nu.pid) {
        print "Lock acquired"
    } else {
        print $"Failed to acquire lock ($nu.pid)"
        exit 1
    }

    def get_device_names [] {
        let ddcutil_output = ${pkgs.ddcutil}/bin/ddcutil detect -t
        print $ddcutil_output

        $ddcutil_output | lines | where { str contains "/dev/" } | parse --regex ".*/dev/(?P<dev>i2c-.*)" | get dev
    }

    mut device_names = (get_device_names)

    print $device_names

    # todo: make this configurable, probably count the number of monitors in an future opts.system.monitors option
    while (($device_names | length) != 3) {
        sleep 2sec
        $device_names = (get_device_names)
        print $device_names
    }
    print $device_names

    sleep 5sec

    let target_files = $device_names | each { $"/sys/bus/i2c/devices/($in)/new_device" }
    $target_files | each { |it| try { "ddcci 0x37" | save -f $it } }
    print $target_files
  '';
  dbusService = pkgs.writeTextFile {
    name = systemdUnitName;
    destination = "/share/dbus-1/system-services/${serviceName}.service";
    text = ''
      [D-BUS Service]
      Name=${serviceName}
    '';
  };
  dbusServicePolicy = pkgs.writeTextDir "etc/dbus-1/system.d/${serviceName}.conf" ''
    <busconfig>
      <policy group="users">
        <allow send_destination="${serviceName}"/>
      </policy>
    </busconfig>
  '';
  callServicePkg = pkgs.nu.writeScriptBin callServicePkgName ''
    $env.DBUS_SYSTEM_BUS_ADDRESS = "unix:path=/run/dbus/system_bus_socket"
    ${pkgs.dbus}/bin/dbus-send --system / ${serviceName}.${methodName}
  '';
in
{
  options = {
    opts.system.hardware.gpu.nvidia.monitorDdcciFixEnable = lib.mkEnableOption "Enable Nvidia DDC/CI monitor fix";
  };
  config = lib.mkIf config.opts.system.hardware.gpu.nvidia.monitorDdcciFixEnable {
    environment.systemPackages = [ callServicePkg ];
    services.dbus.packages = [ dbusService dbusServicePolicy ];
    systemd.services."${systemdServiceName}" = {
      enable = true;
      description = "Nvidia DDC/CI monitor fix";
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "simple";
        ExecStart = "${serviceStartPkg}";
        Restart = "always";
      };
    };
  };
}
