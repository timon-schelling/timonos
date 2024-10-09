inputs: self: super: {
  hyprland = inputs.hyprland.packages.${super.system}.default;
  # hyprland-plugins = {
  #   touch-gestures = inputs.hyprland-plugin-touch-gestures.packages.${super.system}.default;
  #   virtual-desktops = inputs.hyprland-plugin-virtual-desktops.packages.${super.system}.default;
  # };
}
