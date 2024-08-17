{
  inputs = {
    nixpkgs.url = "git+https://github.com/nixos/nixpkgs?ref=nixos-unstable";
    home-manager = {
      url = "git+https://github.com/nix-community/home-manager?ref=master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    disko = {
      url = "git+https://github.com/nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    impermanence.url = "git+https://github.com/nix-community/impermanence";
    nix-systems-default-linux.url = "git+https://github.com/nix-systems/default-linux";
    hyprland = {
      url = "git+https://github.com/hyprwm/Hyprland?submodules=1&ref=refs/tags/v0.41.2";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        systems.follows = "nix-systems-default-linux";
      };
    };
    hyprland-plugin-touch-gestures = {
      url = "github:horriblename/hyprgrass";
      inputs.hyprland.follows = "hyprland";
    };
    hyprland-plugin-virtual-desktops = {
      url = "git+https://github.com/levnikmyskin/hyprland-virtual-desktops";
      inputs = {
        hyprland.follows = "hyprland";
        nixpkgs.follows = "nixpkgs";
      };
    };
    anyrun = {
      url = "git+https://github.com/Kirottu/anyrun";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        systems.follows = "nix-systems-default-linux";
      };
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
    };
}
