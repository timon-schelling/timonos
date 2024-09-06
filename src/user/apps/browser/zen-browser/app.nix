{ config, lib, pkgs, ... }:

let
  buildFirefoxXpiAddon = lib.makeOverridable ({ stdenv ? pkgs.stdenv
    , fetchurl ? pkgs.fetchurl, pname, version, addonId, url, sha256, ...
    }:
    stdenv.mkDerivation {
      name = "${pname}-${version}";
      src = fetchurl { inherit url sha256; };
      preferLocalBuild = true;
      allowSubstitutes = true;
      passthru = { inherit addonId; };
      buildCommand = ''
        dst="$out/share/mozilla/extensions/{ec8030f7-c20a-464f-9b0e-13a3a9e97384}"
        mkdir -p "$dst"
        install -v -m644 "$src" "$dst/${addonId}.xpi"
      '';
    });

in
{
  platform.user.persist.folders = [
    ".zen/main"
    # ".cache/mozilla"
  ];

  programs.zen-browser = {
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
      DefaultDownloadDirectory = "~/tmp";

      Preferences = {
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
    };

    profiles."main" = {
      name = "main";
      settings = {
        "extensions.autoDisableScopes" = 0;
      };
      extensions = [
        (buildFirefoxXpiAddon {
          pname = "perfect-dark-theme";
          version = "1.1";
          addonId = "{47a97a22-13b8-410a-9bd8-2bf689498872}";
          url = "https://addons.mozilla.org/firefox/downloads/file/3869647/perfect_dark_theme-1.1.xpi";
          sha256 = "sha256-dEPynn2Rhf+G9c9PUpMHErZmfpq5+4oawEk1wmktjFc=";
        })
        (buildFirefoxXpiAddon {
          pname = "darkreader";
          version = "4.9.88";
          addonId = "addon@darkreader.org";
          url = "https://addons.mozilla.org/firefox/downloads/file/4317971/darkreader-4.9.88.xpi";
          sha256 = "sha256-epZdWIC+n7+L6BoQas0ZaCY7GswtsK3VgLMPLdcZVLM=";
        })
        (buildFirefoxXpiAddon {
          pname = "user-agent-string-switcher";
          version = "0.5.0";
          addonId = "{a6c4a591-f1b2-4f03-b3ff-767e5bedf4e7}";
          url = "https://addons.mozilla.org/firefox/downloads/file/4098688/user_agent_string_switcher-0.5.0.xpi";
          sha256 = "sha256-ncjaPIxG1PBNEv14nGNQH6ai9QL4WbKGk5oJDbY+rjM=";
        })
      ];
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
