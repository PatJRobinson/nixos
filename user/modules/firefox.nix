{
  lib,
  pkgs,
  hostParams,
  ...
}: let
  themeColors = builtins.fromJSON (builtins.readFile ./firefox/dayfox.json);
  rgb = name: "rgb(${lib.concatMapStringsSep ", " toString themeColors.${name}})";
  dayfox =
    lib.replaceStrings
    ["@background@" "@surface@" "@foreground@" "@muted@" "@border@" "@blue@"]
    [(rgb "background") (rgb "surface") (rgb "foreground") (rgb "muted") (rgb "border") (rgb "blue")];

  startPagePort = 8766;
  startPageUrl = "http://127.0.0.1:${toString startPagePort}/";
  # Edit this list to change the links on every profile's new-tab page.
  startPageShortcuts = [
    {
      name = "YouTube";
      url = "https://www.youtube.com/feed/subscriptions";
    }
    {
      name = "GitHub";
      url = "https://github.com/";
    }
    {
      name = "Nix Packages";
      url = "https://search.nixos.org/packages";
    }
    {
      name = "NixOS Wiki";
      url = "https://wiki.nixos.org/";
    }
  ];
  startPageHtml = dayfox (lib.replaceStrings
    ["@shortcuts@"]
    [(lib.concatMapStringsSep "\n" (link: ''<a href="${lib.escapeXML link.url}">${lib.escapeXML link.name}</a>'') startPageShortcuts)]
    (builtins.readFile ./firefox/startpage.html));
  startPage = pkgs.writeTextDir "index.html" startPageHtml;

  profile = name: id: {
    inherit id;
    isDefault = id == 0;
    # A dedicated path avoids taking over an existing Firefox profile's files.
    path = "nix-${name}";
    userChrome = dayfox (builtins.readFile ./firefox/userChrome.css);
    userContent = dayfox (builtins.readFile ./firefox/userContent.css);
    settings = {
      "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
      "browser.compactmode.show" = true;
      "browser.uidensity" = 1;
      "browser.tabs.inTitlebar" = 1;
      "browser.tabs.drawInTitlebar" = true;
      "browser.tabs.tabMinWidth" = 90;
      "browser.toolbars.bookmarks.visibility" = "never";
      "browser.urlbar.trimURLs" = false;
      "browser.urlbar.showSearchTerms.enabled" = false;
      "browser.startup.page" =
        if name == "google" || name == "personal"
        then 1
        else 3;
      "browser.startup.homepage" =
        if name == "google"
        then "https://www.youtube.com/"
        else if name == "personal"
        then startPageUrl
        else "about:home";
      "browser.aboutwelcome.enabled" = false;
      "browser.shell.checkDefaultBrowser" = false;
      "browser.newtabpage.activity-stream.showSponsored" = false;
      "browser.newtabpage.activity-stream.showSponsoredTopSites" = false;
      "browser.newtabpage.activity-stream.feeds.section.topstories" = false;
      "sidebar.revamp" = false;
      "sidebar.verticalTabs" = false;
      "sidebar.main.tools" = "";
      "extensions.activeThemeID" = "firefox-compact-light@mozilla.org";
      # Sign in once per profile; account tokens and device IDs stay in Firefox.
      "identity.fxaccounts.enabled" = true;
      "identity.fxaccounts.account.device.name" = "${hostParams.name or "nixos"} / ${name}";
      # Sync only the requested browsing data. Nix owns appearance/extensions.
      "services.sync.engine.prefs" = false;
      "services.sync.engine.addons" = false;
      "services.sync.engine.bookmarks" = true;
      "services.sync.engine.tabs" = true;
      "services.sync.engine.history" = false;
      "services.sync.engine.passwords" = false;
      "services.sync.engine.addresses" = false;
      "services.sync.engine.creditcards" = false;
    };
    search = {
      force = true;
      default = "ddg";
      privateDefault = "ddg";
      engines = {
        "Nix Packages" = {
          urls = [{template = "https://search.nixos.org/packages?query={searchTerms}";}];
          definedAliases = ["@nix"];
        };
        "NixOS Wiki" = {
          urls = [{template = "https://wiki.nixos.org/w/index.php?search={searchTerms}";}];
          definedAliases = ["@nw"];
        };
      };
    };
  };
  extension = slug: {
    install_url = "https://addons.mozilla.org/firefox/downloads/latest/${slug}/latest.xpi";
    installation_mode = "force_installed";
    default_area = "menupanel";
  };
in {
  programs.firefox = {
    enable = true;
    configPath = ".mozilla/firefox";
    nativeMessagingHosts = [pkgs.tridactyl-native];
    profiles = {
      personal = profile "personal" 0;
      work = profile "work" 1;
      google = profile "google" 2;
      uwe-student = profile "uwe-student" 3;
      uwe-staff = profile "uwe-staff" 4;
      calyo = profile "calyo" 5;
    };
    # Install signed AMO extensions and let Firefox update them independently of
    # rebuilds. This is deliberate for timely YouTube blocking fixes.
    policies = {
      DisableTelemetry = true;
      DisableFirefoxStudies = true;
      DontCheckDefaultBrowser = true;
      ExtensionSettings = {
        "tridactyl.vim@cmcaine.co.uk" = extension "tridactyl-vim";
        "uBlock0@raymondhill.net" = extension "ublock-origin";
        "myallychou@gmail.com" = extension "youtube-recommended-videos";
      };
      "3rdparty".Extensions."uBlock0@raymondhill.net" = {
        userSettings = [
          ["autoUpdate" "true"]
          ["advancedUserEnabled" "false"]
        ];
        toOverwrite = {
          filterLists = [
            "user-filters"
            "ublock-filters"
            "ublock-badware"
            "ublock-privacy"
            "ublock-quick-fixes"
            "ublock-unbreak"
            "easylist"
            "easyprivacy"
            "urlhaus-1"
            "plowe-0"
          ];
          filters = lib.splitString "\n" (builtins.readFile ./firefox/ublock-filters.txt);
        };
      };
    };
  };

  xdg.configFile = {
    "tridactyl/tridactylrc".text = lib.replaceStrings ["@startpage-url@"] [startPageUrl] (builtins.readFile ./firefox/tridactylrc);
    "tridactyl/themes/dayfox.css".text = dayfox (builtins.readFile ./firefox/tridactyl-dayfox.css);
  };

  home.sessionVariables = {
    BROWSER = "firefox";
    MOZ_ENABLE_WAYLAND = "1";
  };
  home.packages = [pkgs.nerd-fonts.jetbrains-mono];
  home.file.".local/share/icons/hicolor/scalable/apps/firefox-google.svg".source = ./application-icons/firefox-google.svg;
  home.file.".local/share/icons/hicolor/scalable/apps/firefox-uwe-student.svg".source = ./application-icons/firefox-uwe-student.svg;
  home.file.".local/share/icons/hicolor/scalable/apps/firefox-uwe-staff.svg".source = ./application-icons/firefox-uwe-staff.svg;
  home.file.".local/share/icons/hicolor/scalable/apps/firefox-calyo.svg".source = ./application-icons/firefox-calyo.svg;

  # A normal HTTP document supports Tridactyl's content script and hinting;
  # Firefox's about:blank and arbitrary extension pages do not.
  systemd.user.services.firefox-startpage = {
    Unit.Description = "Firefox Dayfox start page";
    Service = {
      ExecStart = "${lib.getExe pkgs.python3} -m http.server ${toString startPagePort} --bind 127.0.0.1 --directory ${startPage}";
      Restart = "on-failure";
      RestartSec = 2;
      NoNewPrivileges = true;
    };
    Install.WantedBy = ["default.target"];
  };
  xdg.mimeApps = {
    enable = true;
    defaultApplications = lib.genAttrs [
      "text/html"
      "application/xhtml+xml"
      "x-scheme-handler/http"
      "x-scheme-handler/https"
    ] (_: ["firefox.desktop"]);
  };
  # Replace the existing empty legacy file with Home Manager's generated link.
  xdg.dataFile."applications/mimeapps.list".force = true;
  xdg.desktopEntries.firefox-work = {
    name = "Firefox (Work)";
    genericName = "Web Browser";
    exec = "firefox -P work %U";
    icon = "firefox";
    terminal = false;
    categories = ["Network" "WebBrowser"];
  };
  xdg.desktopEntries.firefox-google = {
    name = "Firefox (Google)";
    genericName = "Web Browser";
    exec = "firefox -P google %U";
    icon = "firefox-google";
    terminal = false;
    categories = ["Network" "WebBrowser"];
  };
  xdg.desktopEntries.firefox-uwe-student = {
    name = "Firefox (UWE Student)";
    genericName = "Web Browser";
    exec = "${pkgs.coreutils}/bin/env MOZ_APP_REMOTINGNAME=firefox-uwe-student firefox -P uwe-student %U";
    icon = "firefox-uwe-student";
    settings.StartupWMClass = "firefox-uwe-student";
    terminal = false;
    categories = ["Network" "WebBrowser"];
  };
  xdg.desktopEntries.firefox-uwe-staff = {
    name = "Firefox (UWE Staff)";
    genericName = "Web Browser";
    exec = "${pkgs.coreutils}/bin/env MOZ_APP_REMOTINGNAME=firefox-uwe-staff firefox -P uwe-staff %U";
    icon = "firefox-uwe-staff";
    settings.StartupWMClass = "firefox-uwe-staff";
    terminal = false;
    categories = ["Network" "WebBrowser"];
  };
  xdg.desktopEntries.firefox-calyo = {
    name = "Firefox (Calyo)";
    genericName = "Web Browser";
    exec = "${pkgs.coreutils}/bin/env MOZ_APP_REMOTINGNAME=firefox-calyo firefox -P calyo %U";
    icon = "firefox-calyo";
    settings.StartupWMClass = "firefox-calyo";
    terminal = false;
    categories = ["Network" "WebBrowser"];
  };
}
