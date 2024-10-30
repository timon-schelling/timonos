{ pkgs, ... }:

{
  programs.anyrun = {
    enable = true;
    package = pkgs.anyrun;
    config = {
      plugins = [
        "${pkgs.anyrun}/lib/libapplications.so"
        "${pkgs.anyrun}/lib/librink.so"
        "${pkgs.anyrun}/lib/libsymbols.so"
        "${pkgs.anyrun}/lib/libwebsearch.so"
      ];
      width = { absolute = 1000; };
      x = { fraction = 0.5; };
      y = { absolute = 30; };
      hideIcons = false;
      ignoreExclusiveZones = false;
      layer = "overlay";
      hidePluginInfo = false;
      closeOnClick = true;
      showResultsImmediately = true;
      maxEntries = 16;
    };

    extraConfigFiles = {
      "applications.ron".text = ''
        Config(
          desktop_actions: false,
          max_entries: 10,
          terminal: Some("rio"),
        )
      '';

      "websearch.ron".text = ''
        Config(
          prefix: "?",
          engines: [Google, DuckDuckGo]
        )
      '';

      "symbols.ron".text = ''
        Config(
          prefix: "$",
          symbols: {},
          max_entries: 50,
        )
      '';

      "stdin.ron".text = ''
        Config(
          allow_invalid: false,
          max_entries: 1000000
        )
      '';
    };
  };

  home.packages = [
    (pkgs.nu.writeScriptBin "select-ui" ''
      anyrun-select
    '')
    (pkgs.nu.writeScriptBin "anyrun-select"''
      ^anyrun --plugins "${pkgs.anyrun}/lib/libstdin.so" --hide-plugin-info true
    '')
  ];

  programs.anyrun.extraCss = ''
    @define-color bg_0 #202020;
    @define-color bg_1 #272727;
    @define-color bg_2 #343434;
    @define-color fg_0 #AAAAAA;
    @define-color fg_1 #888888;
    @define-color fg_2 #666666;

    @define-color window_background @bg_0;
    @define-color window_foreground @fg_0;
    @define-color window_border @bg_2;
    @define-color entry_bg @bg_1;
    @define-color entry_fg @fg_1;
    @define-color entry_border @bg_1;
    @define-color result_bg @bg_1;
    @define-color result_fg @fg_1;
    @define-color result_selected_bg @bg_2;
    @define-color result_selected_fg @fg_0;

    * {
      all: unset;
      font-family: "SF Pro Rounded", RecMonoLinear;
      font-size: 16px;
    }

    #main {
      background: @window_background;
      color: @window_foreground;
      border: 3px solid @window_border;
      border-radius: 18px;
      padding: 12px 10px 12px 10px;
    }

    list#main {
      border: 0px;
      padding: 0px;
    }

    #plugin.activatable {
      padding: 0px 0px 12px 0px;
    }

    #plugin.activatable:first-child {
      padding-top: 12px;
    }

    #plugin.activatable:last-child {
      padding-bottom: 0px;
    }

    #entry {
      background: @entry_bg;
      color: @entry_fg;
      border-radius: 12px;
      padding: 10px;
      font-size: 24px;
      min-height: 44px;
    }

    box > box#plugin.horizontal:first-child {
      border-width: 0px;
    }

    #match.activatable {
      border-radius: 12px;
      background: @result_bg;
      color: @result_fg;
      margin: 0px 0px 12px 0px;
      padding: 10px;
      min-height: 44px;
    }

    #match.activatable:last-child {
      margin: 0px 0px 0px 0px;
    }

    #match:selected, #match:hover {
      background: @result_selected_bg;
      color: @result_selected_fg;
    }
  '';
}
