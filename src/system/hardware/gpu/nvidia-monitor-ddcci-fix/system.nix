{ pkgs, lib, config, ... }:

let
  callServicePkgName = "monitor-fix-ddcci-nvidia";
  serviceName = "zip.timon.os.System.NvidiaDdcciMonitorFix";
  methodName = "fix";
  systemdServiceName = "nvidia-ddcci-monitor-fix";
  systemdUnitName = "${systemdServiceName}.service";
  serviceStartPkg = pkgs.nu.writeScript systemdServiceName ''
    $env.DBUS_SYSTEM_BUS_ADDRESS = "unix:path=/run/dbus/system_bus_socket"
    exec ${lib.getExe pkgs.dbus-listen} --system --interface ${serviceName} --member ${methodName} ${scriptPkg}
  '';
  scriptPkg = pkgs.nu.writeScript "ddcci-load-i2c-devices" ''
    let lock_file = '/var/lock/ddcci-load-i2c-devices'

    if ($lock_file | path exists) {
        exit 0
    }

    $nu.pid | save $lock_file

    if ((open $lock_file | into int) == $nu.pid) {
        print $"Lock acquired pid ($nu.pid)"
    } else {
        print $"Failed to acquire lock pid ($nu.pid)"
        exit 1
    }

    def get_device_names [] {
        let ddcutil_output = ${lib.getExe pkgs.ddcutil} detect -t
        print $ddcutil_output

        $ddcutil_output | lines | where { str contains "/dev/" } | parse --regex ".*/dev/(?P<dev>i2c-.*)" | get dev
    }

    mut device_names = (get_device_names)

    let target_files = $device_names | each { $"/sys/bus/i2c/devices/($in)/new_device" }
    $target_files | par-each { |it|
      try { "ddcci 0x37" | save -f $it }
      print $"done with ($it) at (date now | format date "%Y-%m-%d_%H:%M:%S")"
    }

    print $"Returning lock and exiting pid ($nu.pid)"
    rm $lock_file
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
