{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    impermanence.url = "github:nix-community/impermanence";
    contain = {
      url = "github:timon-schelling/contain";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = inputs:
    let
      pkgs = inputs.nixpkgs;
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];
      forAllSystems = f: pkgs.lib.genAttrs systems (system: f system);

      lib = pkgs.lib.extend (_: _: import ./lib { lib = pkgs.lib;});
      overlays = (map (e: import e inputs) (lib.imports.type "overlay" ./overlays));
      hostDirs = (lib.attrsets.filterAttrs (file: kind: kind == "directory" ) (builtins.readDir ./hosts));
      hostNames = builtins.attrNames hostDirs;
      mkHost = host: inputs: import ./src/main.nix { inherit host lib overlays inputs; };
      hosts = builtins.foldl' (acc: host: acc // { "${host}" = (mkHost host inputs); }) {} hostNames;
    in
    {
      nixosConfigurations = hosts;
      legacyPackages = forAllSystems (system: (
        import pkgs {
          inherit system;
          overlays = overlays;
        }
      ));
    };
}
