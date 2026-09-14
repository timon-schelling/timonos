inputs: self: super: {
  noctalia-greeter = super.noctalia-greeter.overrideAttrs {
    patches = [ ./fix-pam.patch ];
  };
}
