{ host, lib, overlays, inputs, ... }:

lib.nixosSystem {
  specialArgs = {
    inherit inputs lib;
  };
  modules = [

    (../hosts + "/${host}/config.nix")

    {
      imports = (lib.imports.type "system" ./.) ++ [ ../profiles/system/system.nix ];
    }

    {
      opts.system.host = "${host}";
    }

    ./users.nix

    {
      nixpkgs.overlays = overlays;
    }
  ];
}
