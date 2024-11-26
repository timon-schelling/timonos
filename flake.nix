{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-24.11";
    home-manager = {
      # TODO: change to upstream once merged into home-manager
      url = "github:timon-schelling/home-manager?ref=lapce";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    impermanence.url = "github:nix-community/impermanence";
  };
  outputs = inputs:
    let
      pkgs = inputs.nixpkgs;
      lib = pkgs.lib.extend (_: _: import ./lib { lib = pkgs.lib; inherit pkgs; });
      hostDirs = (lib.attrsets.filterAttrs (file: kind: kind == "directory" ) (builtins.readDir ./hosts));
      hosts = builtins.attrNames hostDirs;
      system = host: inputs: import ./src/main.nix { inherit host lib pkgs inputs; };
      systems = builtins.foldl' (acc: host: acc // { "${host}" = (system host inputs); }) {} hosts;
    in
    {
      nixosConfigurations = systems;
    };
}
