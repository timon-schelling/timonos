inputs: self: super: {
  contain-unwrapped = (self.callPackage ./package.nix {});
  contain = (self.runCommand "contain" {
        buildInputs = [ self.makeWrapper ];
  } ''
    makeWrapper ${self.contain-unwrapped}/bin/contain $out/bin/contain --set PATH ${self.lib.makeBinPath (with self; [ cloud-hypervisor-graphics virtiofsd crosvm-gpu-only ])}
  '');
  containd = (self.runCommand "containd" {
        buildInputs = [ self.makeWrapper ];
  } ''
    makeWrapper ${self.contain-unwrapped}/bin/containd $out/bin/containd --set PATH ${self.lib.makeBinPath (with self; [ iproute2 ])}
  '');

  contain-optimized-kernel-unwrapped = (self.linuxManualConfig (
    let
      base = self.linuxPackages_6_12;
    in {
      version = base.kernel.version;
      src = base.kernel.src;
      configfile = ./optimized-kernel-config;
    }
    )
  );
  contain-optimized-kernel = (self.runCommand "contain-optimized-kernel-image" {} ''
    ln -s ${self.contain-optimized-kernel-unwrapped}/bzImage $out
  '');
}
