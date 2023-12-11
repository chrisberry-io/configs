# This is your home-manager configuration file
# Use this to configure your home environment (it replaces ~/.config/nixpkgs/home.nix)
{ inputs
, lib
, config
, pkgs
, pkgs-unstable
, ...
}:
{
  # You can import other home-manager modules here
  imports = [
    # If you want to use home-manager modules from other flakes (such as nix-colors):
    # inputs.nix-colors.homeManagerModule

    # You can also split up your configuration and import pieces of it here:
    # ./nvim.nix
  ];

  nixpkgs = {
    # You can add overlays here
    overlays = [
      # If you want to use overlays exported from other flakes:
      # neovim-nightly-overlay.overlays.default

      # Or define it inline, for example:
      # (final: prev: {
      #   hi = final.hello.overrideAttrs (oldAttrs: {
      #     patches = [ ./change-hello-to-hi.patch ];
      #   });
      # })
    ];
    # Configure your nixpkgs instance
    config = {
      # Disable if you don't want unfree packages
      allowUnfree = true;
      # Workaround for https://github.com/nix-community/home-manager/issues/2942
      allowUnfreePredicate = _: true;
    };
  };

  home = {
    username = "chris";
    homeDirectory = "/home/chris";
  };

  # Add stuff for your user as you see fit:
  # programs.neovim.enable = true;
  # home.packages = with pkgs; [ steam ];
  programs = {
    git = {
      enable = true;
      userName = "Chris";
      userEmail = "chrisberry08@gmail.com";
    };
    nushell = {
      enable = true;
      extraConfig = ''
        $env.config = {
          show_banner: false,
        }
      '';
    };
    starship = {
      enable = true;
    };
    vscode = {
      enable = true;
      extensions = with pkgs.vscode-extensions; [
        bbenoist.nix
        github.copilot
        jnoortheen.nix-ide
      ] ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
        {
          name = "houston";
          publisher = "astro-build";
          version = "0.1.2";
          sha256 = "Xs39Sgrvo20MVXCDet14qsQ9adSfbGrKyMUp6AV1YVk=";
        }
      ];
      userSettings = {
        "github.copilot.enable" = {
          "*" = true;
          "markdown" = false;
          "plaintext" = false;
          "scminput" = false;
        };
        "editor.minimap.enabled" = false;
        "window.menuBarVisibility" = "compact";
        "window.titleBarStyle" = "native";
        "workbench.sideBar.location" = "right";
        "workbench.colorTheme" = "Houston";
        "nix.enableLanguageServer" = true;
        "nix.serverPath" = "nil";
        "nix.serverSettings" = {
          "nil" = {
            "formatting" = {
              "command" = [ "nixpkgs-fmt" ];
            };
          };
        };
      };
    };
  };

  # Add Firefox GNOME theme directory
  home.file."firefox-gnome-theme" = {
    target = ".mozilla/firefox/default/chrome/firefox-gnome-theme";
    source = (fetchTarball {
      url = "https://github.com/rafaelmardojai/firefox-gnome-theme/archive/master.tar.gz";
      sha256 = "0jnnay7x5d722nxp89i4a5cj0lm2fn5sap9b92lh5ynp5kbncd6s";
    });
  };

  programs.firefox = {
    enable = true;
    profiles.default = {
      name = "Default";
      settings = {
        "extensions.activeThemeID" = "firefox-compact-dark@mozilla.org";

        # For Firefox GNOME theme:
        "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
        "browser.tabs.drawInTitlebar" = true;
        "svg.context-properties.content.enabled" = true;
      };
      userChrome = ''
        @import "firefox-gnome-theme/userChrome.css";
        @import "firefox-gnome-theme/theme/colors/dark.css"; 
      '';
    };
  };

  dconf.settings = {
    "org/gnome/calculator" = {
      button-mode = "programming";
    };
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
    };
  };

  gtk = {
    enable = true;
    theme = {
      name = "adw-gtk3-dark";
      package = pkgs.adw-gtk3;
    };
  };

  # Enable home-manager and git
  programs.home-manager.enable = true;

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "23.05";
}
