let waybar_pids = (ps | filter { |e| $e.name | str contains -i waybar }).pid
if ($waybar_pids | is-empty) {
    hyprctl dispatch exec waybar
} else {
    $waybar_pids | each { |pid| kill $pid }
}
