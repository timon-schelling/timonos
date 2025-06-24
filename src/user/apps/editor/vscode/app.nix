{ pkgs, lib, ... }:

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
        makeWrapper ${lib.getExe pkgs.vscode} $out/bin/code --set NIXOS_OZONE_WL 1
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
        github.copilot
        github.copilot-chat
        streetsidesoftware.code-spell-checker-german

        pkgs.vscode-extension-jjk
      ] ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
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
