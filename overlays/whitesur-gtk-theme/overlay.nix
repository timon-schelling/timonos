inputs: self: super: {
  whitesur-gtk-theme = self.callPackage ./package.nix { gnome-shell = self.gnome-shell; };
}
