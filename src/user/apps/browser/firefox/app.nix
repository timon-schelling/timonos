{ config, lib, pkgs, ... }:

{
  platform.user.persist.folders = [
    ".mozilla/firefox/main"
    # ".cache/mozilla"
  ];

  programs.firefox = {
    enable = true;
    policies = {
      DisableTelemetry = true;
      DisableFirefoxStudies = true;
      EnableTrackingProtection = {
        Value = true;
        Locked = true;
        Cryptomining = true;
        Fingerprinting = true;
      };
      DisablePocket = true;
      DisableFirefoxAccounts = true;
      DisableAccounts = true;
      DisableFirefoxScreenshots = true;
      OverrideFirstRunPage = "";
      OverridePostUpdatePage = "";
      DontCheckDefaultBrowser = true;
      DisplayBookmarksToolbar = "never";
      DisplayMenuBar = "default-off";
      SearchBar = "unified";
      DefaultDownloadDirectory = "\${home}/tmp";

      Preferences = {
        "browser.newtabpage.pinned" = [{
          title = "NixOS";
          url = "https://nixos.org";
        }];
        "browser.contentblocking.category" = "strict";
        "browser.disableResetPrompt" = true;
        "browser.download.panel.shown" = true;
        "browser.formfill.enable" = false;
        "browser.newtabpage.activity-stream.feeds.section.topstories" = false;
        "browser.newtabpage.activity-stream.feeds.snippets" = false;
        "browser.newtabpage.activity-stream.feeds.telemetry" = false;
        "browser.newtabpage.activity-stream.section.highlights.includeBookmarks" = false;
        "browser.newtabpage.activity-stream.section.highlights.includeDownloads" = false;
        "browser.newtabpage.activity-stream.section.highlights.includePocket" = false;
        "browser.newtabpage.activity-stream.section.highlights.includeVisited" = false;
        "browser.newtabpage.activity-stream.showSponsored" = false;
        "browser.newtabpage.activity-stream.showSponsoredTopSites" = false;
        "browser.newtabpage.activity-stream.system.showSponsored" = false;
        "browser.newtabpage.activity-stream.telemetry" = false;
        "browser.ping-centre.telemetry" = false;
        "browser.search.suggest.enabled.private" = false;
        "browser.search.suggest.enabled" = false;
        "browser.shell.checkDefaultBrowser" = false;
        "browser.shell.defaultBrowserCheckCount" = 1;
        "browser.topsites.contile.enabled" = false;
        "browser.urlbar.showSearchSuggestionsFirst" = false;
        "browser.urlbar.suggest.searches" = false;
        "dom.security.https_only_mode" = true;
        "experiments.activeExperiment" = false;
        "experiments.enabled" = false;
        "experiments.supported" = false;
        "extensions.InstallTrigger.enabled" = false;
        "extensions.pocket.enabled" = false;
        "extensions.screenshots.disabled" = true;
        "full-screen-api.ignore-widgets" = true;
        "general.smoothScroll" = true;
        "identity.fxaccounts.enabled" = false;
        "media.ffmpeg.vaapi.enabled" = true;
        "media.rdd-vpx.enabled" = true;
        "network.allow-experiments" = false;
        "privacy.donottrackheader.enabled" = true;
        "privacy.partition.network_state.ocsp_cache" = true;
        "privacy.trackingprotection.enabled" = true;
        "privacy.trackingprotection.socialtracking.enabled" = true;
        "privacy.userContext.enabled" = false;
        "signon.rememberSignons" = false;
        "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
        "toolkit.telemetry.archive.enabled" = false;
        "toolkit.telemetry.bhrPing.enabled" = false;
        "toolkit.telemetry.enabled" = false;
        "toolkit.telemetry.firstShutdownPing.enabled" = false;
        "toolkit.telemetry.hybridContent.enabled" = false;
        "toolkit.telemetry.newProfilePing.enabled" = false;
        "toolkit.telemetry.reportingpolicy.firstRun" = false;
        "toolkit.telemetry.shutdownPingSender.enabled" = false;
        "toolkit.telemetry.unified" = false;
        "toolkit.telemetry.updatePing.enabled" = false;
        "widget.use-xdg-desktop-portal.file-picker" = true;
        "widget.use-xdg-desktop-portal.location" = true;
        "widget.use-xdg-desktop-portal.mime-handler" = true;
        "widget.use-xdg-desktop-portal.open-uri" = true;
        "widget.use-xdg-desktop-portal.settings" = true;
        "browser.uiCustomization.state" = (builtins.toJSON {
          currentVersion = 20;
          dirtyAreaCache = [
            "unified-extensions-area"
            "nav-bar"
            "toolbar-menubar"
            "TabsToolbar"
            "PersonalToolbar"
          ];
          newElementCount = 4;
          placements = {
            PersonalToolbar = [ "import-button" "personal-bookmarks" ];
            TabsToolbar = [ "tabbrowser-tabs" "new-tab-button" "alltabs-button" ];
            nav-bar = [
              "back-button"
              "forward-button"
              "stop-reload-button"
              "urlbar-container"
              "downloads-button"
              "fxa-toolbar-menu-button"
              "reset-pbm-toolbar-button"
              "unified-extensions-button"
            ];
            toolbar-menubar = [ "menubar-items" ];
            unified-extensions-area = [
              "addon_darkreader_org-browser-action"
              "_a6c4a591-f1b2-4f03-b3ff-767e5bedf4e7_-browser-action"
            ];
            widget-overflow-fixed-list = [ ];
          };
          seen = [
            "addon_darkreader_org-browser-action"
            "_a6c4a591-f1b2-4f03-b3ff-767e5bedf4e7_-browser-action"
            "developer-button"
          ];
        });
      };

      ExtensionSettings = with builtins;
        let extension = shortId: uuid: {
          name = uuid;
          value = {
            install_url = "https://addons.mozilla.org/en-US/firefox/downloads/latest/${shortId}/latest.xpi";
            installation_mode = "force_installed";
          };
        };
        in listToAttrs [
          (extension "perfectdarktheme" "")
          (extension "darkreader" "addon@darkreader.org")
          (extension "user-agent-string-switcher" "{a6c4a591-f1b2-4f03-b3ff-767e5bedf4e7}")
          # (extension "tree-style-tab" "treestyletab@piro.sakura.ne.jp")
          # (extension "uborigin" "uBlock0@raymondhill.net")
          # (extension "clearurls" "{74145f27-f039-47ce-a470-a662b129930a}")
        ];
        # To add additional extensions,find it on addons.mozilla.org, find
        # the short ID in the url (like !SHORT_ID!/)
        # install it in firefox, then go to about:support#addons, or
        # download the XPI by filling it in to the install_url template, unzip it,
        # run `jq .browser_specific_settings.gecko.id manifest.json` or
        # `jq .applications.gecko.id manifest.json` to get the UUID
    };

    profiles.main = {
      name = "main";
      extraConfig = ''
      '';
      userChrome = ''
        :root{--in-content-bg-dark:rgb(35, 35, 35);}

        .titlebar-buttonbox-container{ display:none }

        @-moz-document plain-text-document(), media-document(all) {
            :root {
                background-color: var(--in-content-bg-dark) !important;
            }
            body:not([style*="background"], [class], [id]) {
                background-color: transparent !important;
            }
        }
        @-moz-document regexp("view-source:.*") {
            :root,
            body {
                background-color: var(--in-content-bg-dark);
            }
        }
        @-moz-document url-prefix("about:debugging") {
            :root {
                --box-background: var(--in-content-bg-dark) !important;
            }
        }
        @-moz-document url-prefix("about:reader") {
            body.dark {
                --main-background: var(--in-content-bg-dark) !important;
                --tooltip-background: color-mix(in srgb, black 40%, var(--in-content-bg-dark)) !important;
            }
        }

        @-moz-document regexp("^(about:|chrome:|moz-extension:).*") {
            html:not([role="dialog"]),
            html:not([role="dialog"]) *,
            html:not([role="dialog"]) body.activity-stream,
            window:not([chromehidden]),
            window:not([chromehidden]) > dialog {
                --in-content-page-background: hsl(270, 3%, 12%) !important;
                --newtab-background-color: var(--in-content-page-background) !important;
            }
        }
      '';
      search = {
        force = true;
        default = "Google";
        engines = {
          "Nix Packages" = {
            urls = [
              {
                template = "https://search.nixos.org/packages";
                params = [
                  {
                    name = "type";
                    value = "packages";
                  }
                  {
                    name = "channel";
                    value = "unstable";
                  }
                  {
                    name = "query";
                    value = "{searchTerms}";
                  }
                ];
              }
            ];
            definedAliases = ["@np"];
          };
          "Nix Options" = {
            urls = [
              {
                template = "https://search.nixos.org/options";
                params = [
                  {
                    name = "type";
                    value = "packages";
                  }
                  {
                    name = "channel";
                    value = "unstable";
                  }
                  {
                    name = "query";
                    value = "{searchTerms}";
                  }
                ];
              }
            ];
            definedAliases = ["@no"];
          };
          "Home Manager" = {
            urls = [
              {
                template = "https://home-manager-options.extranix.com/";
                params = [
                  {
                    name = "query";
                    value = "{searchTerms}";
                  }
                ];
              }
            ];
            definedAliases = ["@hm"];
          };
          "GitHub" = {
            urls = [
              {
                template = "https://github.com/search";
                params = [
                  {
                    name = "q";
                    value = "{searchTerms}";
                  }
                ];
              }
            ];
            definedAliases = ["@gh"];
          };
          "GitLab" = {
            urls = [
              {
                template = "https://gitlab.com/search";
                params = [
                  {
                    name = "search";
                    value = "{searchTerms}";
                  }
                ];
              }
            ];
            definedAliases = ["@gl"];
          };
          "YouTube" = {
            urls = [
              {
                template = "https://www.youtube.com/results";
                params = [
                  {
                    name = "search_query";
                    value = "{searchTerms}";
                  }
                ];
              }
            ];
            definedAliases = ["@yt"];
          };
          "DuckDuckGo" = {
            urls = [
              {
                template = "https://duckduckgo.com/";
                params = [
                  {
                    name = "q";
                    value = "{searchTerms}";
                  }
                ];
              }
            ];
            definedAliases = ["@dg"];
          };
          "Google" = {
            urls = [
              {
                template = "https://www.google.com/search";
                params = [
                  {
                    name = "q";
                    value = "{searchTerms}";
                  }
                ];
              }
            ];
            definedAliases = ["@g"];
          };
          "Wikipedia" = {
            urls = [
              {
                template = "https://en.wikipedia.org/w/index.php";
                params = [
                  {
                    name = "search";
                    value = "{searchTerms}";
                  }
                ];
              }
            ];
            definedAliases = ["@w"];
          };
          "Wikipedia (en)".metaData.hidden = true;
          "Amazon.com".metaData.hidden = true;
          "Bing".metaData.hidden = true;
          "eBay".metaData.hidden = true;
        };
      };
    };
  };
}
