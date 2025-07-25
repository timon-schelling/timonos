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
      lib = pkgs.lib.extend (_: _: import ./lib { lib = pkgs.lib; inherit pkgs; });
      hostDirs = (lib.attrsets.filterAttrs (file: kind: kind == "directory" ) (builtins.readDir ./hosts));
      hosts = builtins.attrNames hostDirs;
      system = host: inputs: import ./src/main.nix { inherit host lib pkgs inputs; };
      systems = builtins.foldl' (acc: host: acc // { "${host}" = (system host inputs); }) {} hosts;
    in
    {
      nixosConfigurations = systems;
      packagesMeta = lib.mergeAttrsList (lib.flatten (lib.mapAttrsToList (name: system: (
        if name == "default" then
          []
        else
          builtins.map
            (x: { ${x.name} = x.meta or []; })
            (
              system.config.environment.systemPackages ++
              (system.config.home-manager.users.timon.home.packages or []) ++
              # (system.config.home-manager.users.timon.programs.vscode.profiles.default.extensions or []) ++
              (system.config.home-manager.users.user.home.packages or []) #++
              # (system.config.home-manager.users.user.programs.vscode.profiles.default.extensions or [])
            )
      )) systems));
    };
}
