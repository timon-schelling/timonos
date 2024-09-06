{ pkgs, ... }:

let
  settings = {
    core = {
      custom-titlebar = false;
      color-theme = "Custom";
      icon-theme = "Material Icons";
    };
    editor = {
      font-family = "FiraCode Nerd Bold Font, monospace";
      font-size = 22;
      tab-width = 2;
      cursor-surrounding-lines = 4;
      render-whitespace = "all";
      bracket-pair-colorization = true;
      highlight-matching-brackets = true;
    };
    ui = {
      font-size = 20;
      open-editors-visible = false;
    };
    nushell-lsp = {
      path = "${pkgs.nushell}/bin/nu";
      args = [ "--lsp" ];
    };
    lapce-nix.lsp-path = "${pkgs.nil}/bin/nil";
    lapce-rust.serverPath = "${pkgs.rust-analyzer}/bin/rust-analyzer";
    typst-lsp.serverPath = "${pkgs.typst-lsp}/bin/typst-lsp";
    lapce-markdown.serverPath = "${pkgs.marksman}/bin/marksman";
  };
  plugins = [
    {
      author = "timon-schelling";
      name = "nushell-lsp";
      version = "0.1.0-rc2";
      hash = "sha256-/s982zGl85kxRoibwSpRiXxXD1Dgq6OUVvMXIUPP//4=";
    }
    {
      author = "MrFoxPro";
      name = "lapce-nix";
      version = "0.0.1";
      hash = "sha256-n+j8p6sB/Bxdp0iY6Gty9Zkpv9Rg34HjKsT1gUuGDzQ=";
    }
    {
      author = "dzhou121";
      name = "lapce-rust";
      version = "0.3.1932";
      hash = "sha256-LJ5tb37aIlTvbW5qCQBs9rOEV9M48BmzGsZD2J6WPw0=";
    }
    {
      author = "nvarner";
      name = "typst-lsp";
      version = "0.13.0";
      hash = "sha256-ibo6fbq7+WvWVZGp1UB8bf+AeXTn70b5fCIkvTmfivQ=";
    }
    {
      author = "zarathir";
      name = "lapce-markdown";
      version = "0.3.2";
      hash = "sha256-+fn9enUr9y663m/3xloFau1yuJ34GDHDVWmOwYrSAbY=";
    }
    {
      author = "panekj";
      name = "lapce-material-icon-theme";
      version = "0.0.1-beta1";
      hash = "sha256-rdnghlwYJy+oE7Fp76LuO+6bIUcYYJzxiJA8kLFKLbE=";
    }
  ];
  keymaps = [
    {
      command = "open_log_file";
      key = "Ctrl+Shift+L";
    }
  ];
  theme = {
    base = {
      white = "#999999";
      black = "#191919";
      grey = "#444444";
      blue = "#1371be";
      red = "#ff6188";
      yellow = "#ffd866";
      orange = "#D19A66";
      green = "#a9dc76";
      purple = "#C678DD";
      cyan = "#32929f";
      magenta = "#ab9df2";
    };
    syntax = {
      attribute = "$orange";
      builtinType = "$cyan";
      comment = "#5C6370";
      constant = "#D62C2C";
      constructor = "$yellow";
      embedded = "$cyan";
      enum = "#9263D3";
      enum-member = "$red";
      enumMember = "#AA63D3";
      escape = "$cyan";
      field = "$red";
      function = "$blue";
      "function.method" = "$blue";
      interface = "#DD46C2";
      keyword = "#14E5D4";
      macro = "#28A9FF";
      method = "#28A9FF";
      number = "$yellow";
      operator = "#EEEEEE60";
      property = "#FF7135";
      selfKeyword = "#14E5D4";
      string = "#a9dc76";
      struct = "#A95EFF";
      structure = "#A95EFF";
      symbol = "$yellow";
      type = "#A95EFF";
      "type.builtin" = "$cyan";
      typeAlias = "#b079ee";
      variable = "#FF478D";
      "variable.other.member" = "$red";
      "variable.parameter" = "#FF478D";
    };
    ui = {
      "activity.background" = "$black";
      "activity.current" = "#353535";
      "completion.background" = "$black";
      "completion.current" = "#353535";
      "editor.background" = "$black";
      "editor.caret" = "#ffb3d6";
      "editor.current_line" = "#aaaaaa0c";
      "editor.dim" = "#bfabfa";
      "editor.focus" = "$white";
      "editor.foreground" = "#dedede";
      "editor.link" = "$cyan";
      "editor.selection" = "#222222";
      "error_lens.error.background" = "#141414";
      "error_lens.error.foreground" = "#FA3232";
      "error_lens.other.background" = "#141414";
      "error_lens.other.foreground" = "#b0b0b0";
      "error_lens.warning.background" = "#141414";
      "error_lens.warning.foreground" = "$yellow";
      "hover.background" = "#595959";
      "inlay_hint.background" = "#221f22";
      "inlay_hint.foreground" = "#969694";
      "lapce.active_tab" = "#161616";
      "lapce.border" = "#1E1E1E";
      "lapce.dropdown_shadow" = "#020202";
      "lapce.error" = "#ff6188";
      "lapce.inactive_tab" = "#101014";
      "lapce.scroll_bar" = "$magenta";
      "lapce.warn" = "$red";
      "markdown.blockquote" = "#a9dc76";
      "palette.background" = "$black";
      "palette.current" = "#262626";
      "panel.background" = "$black";
      "panel.current" = "#262626";
      "panel.hovered" = "#595959";
      "source_control.added" = "#a9dc76";
      "source_control.modified" = "#78dce8";
      "source_control.removed" = "#727072";
      "status.background" = "$black";
      "status.modal.insert" = "$red";
      "status.modal.normal" = "$blue";
      "status.modal.terminal" = "$purple";
      "status.modal.visual" = "$yellow";
      "terminal.background" = "#121212";
      "terminal.black" = "#141414";
      "terminal.blue" = "#fc9867";
      "terminal.bright_black" = "#161616";
      "terminal.bright_blue" = "#fc9867";
      "terminal.bright_cyan" = "#78dce8";
      "terminal.bright_green" = "#a9dc76";
      "terminal.bright_magenta" = "#ab9df2";
      "terminal.bright_red" = "#ff6188";
      "terminal.bright_white" = "#fcfcfa";
      "terminal.bright_yellow" = "#ffd866";
      "terminal.cursor" = "#ffb638";
      "terminal.cyan" = "#78dce8";
      "terminal.foreground" = "#fcfcfa";
      "terminal.green" = "#a9dc76";
      "terminal.magenta" = "#ab9df2";
      "terminal.red" = "#ff6188";
      "terminal.white" = "#fcfcfa";
      "terminal.yellow" = "#ffd866";
    };
  };
in
{
  programs.lapce = {
    enable = true;
    settings = settings;
    plugins = plugins;
    keymaps = keymaps;
  };

  xdg.dataFile."lapce-stable/themes/custom.toml".source = (pkgs.formats.toml {}).generate "custom.toml" {
    color-theme = {
      name = "Custom";
    } // theme;
  };
}
