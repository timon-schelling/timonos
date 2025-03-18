inputs: self: super: {
  crosvm = self.nu.writeScriptBin "crosvm" ''
    def --wrapped main [...args] {
      let display = "wayland-sandboxed-5";
      let socket = $"($env.XDG_RUNTIME_DIR)/($display)";
      $env.WAYLAND_DISPLAY = $display;
      bash -c $"${self.s6}/bin/s6-ipcserver-socketbinder ($socket) ${self.way-secure}/bin/way-secure --app-id vm --socket-fd 0 &"
      sleep 2sec;
      ${self.crosvm-unwrapped}/bin/crosvm ...$args
    }
  '';
  crosvm-unwrapped = (super.callPackage ./package.nix { });
}
