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
        bierner.color-info
        miguelsolorio.min-theme

        pkgs.vscode-extension-jjk
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
