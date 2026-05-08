{ lib, pkgs, config, ... }:

{
  environment.systemPackages = [
    pkgs.claude-code
  ];

  home-manager.users.user.programs.vscode.profiles.default.extensions = [
    pkgs.vscode-extensions.anthropic.claude-code
    pkgs.vscode-extensions.github.copilot
    pkgs.vscode-extensions.github.copilot-chat
    pkgs.vscode-extension-openai-chatgpt
  ];

  home-manager.users.user.opts.user.persist.state.folders = [
    ".claude"
    ".copilot"
    ".codex"
  ];
  home-manager.users.user.opts.user.persist.state.files = [
    ".claude.json"
  ];

  home-manager.users.user.programs.git.ignores = [
    "CLAUDE.md"
    ".claude"
    ".codex"
  ];
}
