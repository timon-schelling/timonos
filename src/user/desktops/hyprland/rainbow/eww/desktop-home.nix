{ pkgs, config, lib, ... }:

{
  programs.eww = {
    enable = true;
    configDir = ./.;
  };

  home.packages =
  let
    mkListenVolumeScript = class: pkgs.writeText "listen-volume.lua" ''
      local class = "${class}"

      Core.require_api("mixer", "default-nodes", function(mixer, default_nodes)
        mixer.scale = "cubic"
        mixer:connect("changed", function(_, node_id)
          if default_nodes:call("get-default-node", class) ~= node_id then
            return
          end
          local volume = mixer:call("get-volume", node_id)
          print(volume.volume)
        end)
        local node_id = default_nodes:call("get-default-node", class)
        local volume = mixer:call("get-volume", node_id)
        print(volume.volume)
      end)
    '';
    mkListenVolumePkg = {
      name,
      class,
      muteCmd,
      unmuteCmd,
    }: pkgs.nu.writeScriptBin name ''
      loop {
        try {
          wpexec ${mkListenVolumeScript class}
          | lines| into float
          | reduce --fold null { |$it, $last|
            if $last != null {
              if $last == 0 and $it != 0 {
                ${unmuteCmd}
              }
              if $last != 0 and $it == 0 {
                ${muteCmd}
              }
            }
            print (($it * 100) | into int)
            $it
          }
        }
      }
    '';
  in [
    (mkListenVolumePkg {
      name = "listen-output-volume";
      class = "Audio/Sink";
      muteCmd = "wpctl set-mute @DEFAULT_AUDIO_SINK@ 1";
      unmuteCmd = "wpctl set-mute @DEFAULT_AUDIO_SINK@ 0";
    })
    (mkListenVolumePkg {
      name = "listen-input-volume";
      class = "Audio/Source";
      muteCmd = "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ 1";
      unmuteCmd = "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ 0";
    })
    (pkgs.nu.writeScriptBin "listen-brightness" ''
      def read_brightness [] {
        ls /sys/class/backlight/*/ | each {
          let brightness = open ($in.name | path join brightness) | into int
          let max_brightness = open ($in.name | path join max_brightness) | into int
          $brightness / $max_brightness * 100
        } | math avg | into int
      }
      print (read_brightness)
      let backlights = ls /sys/class/backlight/*/ | each { $in.name }
      $backlights | par-each -t ($backlights | length) {
        watch -q $"($in | path join brightness)" {
          print (read_brightness)
        }
      }
    '')
    (pkgs.nu.writeScriptBin "listen-cpu-usage" ''
      def get_cpu_times [] {
          open /proc/stat | lines | get 0 | split words | skip 1 | each { $in | into int }
      }
      mut usage_history = []
      mut out_history = []
      mut last_print = 0
      mut since_last_print = 1000
      mut old = get_cpu_times
      loop {
          sleep 100ms
          let new = get_cpu_times
          let delta = $new | zip $old | each { $in.0 - $in.1 }
          $old = $new
          let idle = $delta.3 + $delta.4
          let not_idle = $delta.0 + $delta.1 + $delta.2 + $delta.5 + $delta.6 + $delta.7
          let total = $idle + $not_idle
          let idle_percentage = ($idle / $total)
          let usage = (1 - $idle_percentage) * 100

          $usage_history = $usage_history | append $usage
          if ($usage_history | length) > 10 {
              $usage_history = $usage_history | skip 1
          }

          let out = $usage_history | math avg | each { $in | into float} | math round -p 2
          if (($out - $last_print) | math abs) >= 0.2 or $since_last_print >= 10 {
              $last_print = $out
              $since_last_print = 0
              print $out
          }
          $since_last_print += 1
      }
    '')
    (pkgs.nu.writeScriptBin "listen-mem-usage" ''
      loop {
          print (sys mem | ($in.used / $in.total) * 100 | math round -p 2)
          sleep 200ms
      }
    '')
    (pkgs.nu.writeScriptBin "listen-disk-usage" ''
      loop {
          print (
              sys disks | where mount == "/" | get 0
              | (($in.total - $in.free) / $in.total) * 100 | math round -p 2
          )
          sleep 500ms
      }
    '')
    (pkgs.nu.writeScriptBin "listen-network-connection" ''
      mut network_connection = ""
      loop {
        let new_network_connection = try {
          ip -j link show type "" | from json | compact -e
          | where operstate == "UP" | select ifname
          | insert type { if ($in.ifname =~ "wlan.*") { "wlan" } else { "lan" } }
          | group-by type
          | if "lan" in $in { "lan" } else if "wlan" in $in { "wlan" } else { "down" }
        } catch { "down" }
        if $new_network_connection != $network_connection {
          $network_connection = $new_network_connection
          print $network_connection
        }
        sleep 500ms
      }
    '')
    (pkgs.nu.writeScriptBin "control-panel-toggle" ''
      let screen_id = hyprctl activeworkspace -j | from json | get monitorID
      eww open --screen $screen_id --toggle control-panel
    '')
  ];
}
