{ pkgs, lib, ... }:

{
  platform.user.persist.folders = [
    ".config/zed"
  ];

  programs.zed-editor = {
    enable = true;
    themes."ayu-darker" = ./theme.json;
    extensions = [
      "nix"
      "nu"
    ];
    userSettings = {
      auto_update = false;
      telemetry = {
        diagnostics = false;
        metrics = false;
        anthropic_retention = false;
      };
      proxy = "";
      disable_ai = true;
      icon_theme = {
        mode = "dark";
        light = "Zed (Default)";
        dark = "Zed (Default)";
      };
      ui_font_size = 22;
      ui_font_family = "JetBrainsMono Nerd Font";
      ui_font_weight = 300;
      buffer_font_size = 22;
      buffer_font_family = "FiraCode Nerd Font Mono";
      theme = {
        mode = "dark";
        light = "One Light";
        dark = "Ayu Darker";
      };
      title_bar = {
        show_sign_in = false;
      };
      relative_line_numbers = true;
      cursor_surrounding_lines = 7;
      show_whitespaces = "selection";
      autosave = "on_focus_change";
      remove_trailing_whitespace_on_save = true;
      ensure_final_newline_on_save = true;
      tab_size = 2;
      inlay_hints = {
        enabled = false;
      };
      git = {
        inline_blame = {
          enabled = false;
        };
      };
      lsp = {
        nil = {
          binary = {
            path = lib.getExe pkgs.nil;
          };
        };
        nushell = {
          binary = {
            path = lib.getExe pkgs.nushell;
            args = [ "--lsp" ];
          };
        };
      };
    };
  };

  home.packages = [
    pkgs.nil
  ];
}
