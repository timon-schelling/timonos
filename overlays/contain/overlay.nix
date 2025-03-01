inputs: self: super: {
  contain-unwrapped = (self.callPackage ./package.nix {});
  contain = (self.runCommand "contain" {
        buildInputs = [ self.makeWrapper ];
  } ''
    makeWrapper ${self.contain-unwrapped}/bin/contain $out/bin/contain --set PATH ${self.lib.makeBinPath (with self; [ cloud-hypervisor-graphics virtiofsd crosvm ])}
  '');
  containd = (self.runCommand "containd" {
        buildInputs = [ self.makeWrapper ];
  } ''
    makeWrapper ${self.contain-unwrapped}/bin/containd $out/bin/containd --set PATH ${self.lib.makeBinPath (with self; [ iproute2 ])}
  '');
}
