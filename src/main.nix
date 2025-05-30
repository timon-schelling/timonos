{ host, lib, inputs, ... }:

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
      nixpkgs.overlays = (map (e: import e inputs) (lib.imports.type "overlay" ../overlays));
    }
  ];
}
