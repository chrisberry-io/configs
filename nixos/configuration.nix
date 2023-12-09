# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:
let
  unstable = import <unstable> { config = { allowUnfree = true; }; };
in
{
  imports =
    [
      # Include the results of the hardware scan.
      ./hardware-configuration.nix
      <home-manager/nixos>
    ];

  # Enable Flakes and the new command-line tool
  #nix.settings.experimental-features = [ "nix-command" "flakes" ];


  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "America/New_York";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the GNOME Desktop Environment.
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

  programs.dconf.enable = true;

  # Configure keymap in X11
  services.xserver = {
    layout = "us";
    xkbVariant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Allow "unfree" packages to be installed
  nixpkgs.config = {
    allowUnfree = true;
  };

  # nixpkgs.config.permittedInsecurePackages = [
  #     "figma-linux-0.10.0"
  # ];


  users.defaultUserShell = pkgs.bash;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.chris = {
    isNormalUser = true;
    description = "Chris";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
      firefox
      chromium
      #  thunderbird
    ];
    shell = pkgs.nushell;

  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    #  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    zsh
    gnome.gnome-tweaks
    dconf
    adw-gtk3
    figma-linux
    micro
    gh
    fractal
    element-desktop
    pika-backup
    # Packages with configurations
    #(unstable.vscode-with-extensions.override {
    # vscodeExtensions = with vscode-extensions; [
    #  bbenoist.nix
    #  github.copilot
    #] ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
    # {
    #  name = "houston";
    # publisher = "astro-build";
    #version = "0.1.2";
    #sha256 = "Xs39Sgrvo20MVXCDet14qsQ9adSfbGrKyMUp6AV1YVk=";
    # }
    #];
    # })
  ]
  # unstable packages
  ++ (with unstable; [
    monaspace
    obsidian
  ]);


  home-manager.users.chris = {
    /* The home.stateVersion option does not have a default and must be set */
    home.stateVersion = "23.11";

    /* Here goes the rest of your home-manager config, e.g. home.packages = [ pkgs.foo ]; */

    nixpkgs.config = {
      allowUnfree = true;
    };
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
        extensions = with unstable.vscode-extensions; [
          bbenoist.nix
          github.copilot
          jnoortheen.nix-ide
        ] ++ unstable.vscode-utils.extensionsFromVscodeMarketplace [
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
          "window.menuBarVisibility" = "compact";
          "window.titleBarStyle" = "custom";
          "workbench.sideBar.location" = "right";
          "workbench.colorTheme" = "Houston";
        };
      };
    };

    # Add Firefox GNOME theme directory
    home.file."firefox-gnome-theme" = {
      target = ".mozilla/firefox/default/chrome/firefox-gnome-theme";
      source = (fetchTarball "https://github.com/rafaelmardojai/firefox-gnome-theme/archive/master.tar.gz");
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

  };

  programs.starship.enable = true;

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Personal Services
  services = {
    tailscale = {
      enable = true;
      authKeyFile = "/home/chris/.config/tailscale/tailscale.key";
    };
    syncthing = {
      enable = true;
      user = "chris";
      dataDir = "/home/chris/Documents";
      configDir = "/home/chris/.config/syncthing";
    };
  };


  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?

}