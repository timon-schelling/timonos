inputs: self: super: {
  cage-no-cursor = super.cage.overrideAttrs {
    patches = [ ./hide-cursor.patch ];
  };
}
