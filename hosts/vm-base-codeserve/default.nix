{ lib, pkgs, ... }:

{
  home-manager.users.user = { config, ... }:
    let
      profile = config.programs.vscode.profiles.default;
    in
    {
      home.file.".openvscode-server/data/User/settings.json".text =
        builtins.toJSON profile.userSettings;
      home.file.".openvscode-server/data/User/keybindings.json".text =
        builtins.toJSON (map (lib.filterAttrs (_: v: v != null)) profile.keybindings);

      home.packages = [
        (pkgs.nu.writeScriptBin "codeserve" ''
          def --wrapped main [...args] {
              ${lib.getExe pkgs.openvscode-server} --host 0.0.0.0 --extensions-dir $"($env.HOME)/.vscode/extensions" --default-folder (pwd) ...$args
          }
        '')
      ];
    };
}
