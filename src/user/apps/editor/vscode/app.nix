{ pkgs, ... }:

{
  platform.user.persist.folders = [
    ".config/Code"
    ".vscode"
  ];

  programs.vscode = {
    enable = true;
    package = (pkgs.runCommand "vscode-wayland"
      {
        buildInputs = [ pkgs.makeWrapper ];
        version = pkgs.vscode.version;
        pname = pkgs.vscode.pname;
      }
      ''
        makeWrapper ${pkgs.vscode}/bin/code $out/bin/code --set NIXOS_OZONE_WL 1
        mkdir -p "$out/share/applications/"
        cp "${pkgs.vscode}/share/applications/code.desktop" "$out/share/applications/"
      ''
    );
    mutableExtensionsDir = false;
    profiles.default = {
      extensions = with pkgs.vscode-extensions; [
        jnoortheen.nix-ide
        mhutchie.git-graph
        thenuprojectcontributors.vscode-nushell-lang
        ms-vscode.hexeditor
        streetsidesoftware.code-spell-checker
        pkief.material-icon-theme
      ] ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
        {
          publisher = "github";
          name = "copilot";
          version = "1.301.0";
          sha256 = "sha256-+SOXalkLm89JZ0AtlevVxOxT8bbuTddt8BL5cVfG9qI=";
        }
        {
          publisher = "github";
          name = "copilot-chat";
          version = "0.26.2025032805";
          sha256 = "sha256-6hnp6U089f2yxsFzV0/Vkjsu4FinWIbfkTEIW+4dR3k=";
        }
        {
          publisher = "streetsidesoftware";
          name = "code-spell-checker-german";
          version = "2.3.2";
          sha256 = "sha256-40Oc6ycNog9cxG4G5gCps2ADrM/wLuKWFrD4lnd91Z4=";
        }
        {
          publisher = "bierner";
          name = "color-info";
          version = "0.7.2";
          sha256 = "sha256-Bf0thdt4yxH7OsRhIXeqvaxD1tbHTrUc4QJcju7Hv90=";
        }
        {
          publisher = "miguelsolorio";
          name = "min-theme";
          version = "1.5.0";
          sha256 = "sha256-DF/9OlWmjmnZNRBs2hk0qEWN38RcgacdVl9e75N8ZMY=";
        }
      ];
      enableUpdateCheck = false;
      enableExtensionUpdateCheck = false;
      userSettings = (builtins.fromJSON (builtins.readFile ./settings.json));
      keybindings = (builtins.fromJSON (builtins.readFile ./keybindings.json));
    };
  };

  home.packages = [
    pkgs.nil
  ];
}
