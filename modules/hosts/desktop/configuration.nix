{ self, inputs, ... }:
{
  flake.nixosModules.desktopConfig =
    {
      pkgs,
      config,
      ...
    }:
    {
      imports = [
        self.nixosModules.desktopHardware
        self.nixosModules.gaming
        self.nixosModules.japanese
        self.nixosModules.wiimote
        self.nixosModules.desktopServices
        self.nixosModules.tailscale
        inputs.sops-nix.nixosModules.sops
        inputs.home-manager.nixosModules.default
      ];

      nix.settings = {
        experimental-features = [
          "nix-command"
          "flakes"
        ];
        max-jobs = 8;
        cores = 0;
        auto-optimise-store = true;
      };

      documentation.enable = false;

      nix.gc = {
        automatic = true;
        dates = "weekly";
        options = "--delete-older-than 7d";
      };

      sops.defaultSopsFile = "${self}/secrets/secrets.yaml";
      sops.age.keyFile = "/home/sean/.config/sops/age/keys.txt";
      sops.secrets.luks-password = { };
      sops.secrets.aws-access-key-id = {
        owner = "sean";
      };
      sops.secrets.aws-secret-access-key = {
        owner = "sean";
      };
      sops.secrets.GITHUB_TOKEN = {
        owner = "sean";
      };

      nix.settings.secret-key-files = [ "/var/lib/sops-nix/signing-key.sec" ];

      environment.etc."crypttab".text = ''
        cryptdata /dev/disk/by-uuid/05ac586c-45bc-4a9f-b0cc-96dc8b85b395 ${config.sops.secrets.luks-password.path}
      '';

      fileSystems."/mnt/data" = {
        device = "/dev/mapper/cryptdata";
        fsType = "ext4";
      };

      fileSystems."/mnt/media" = {
        device = "192.168.50.110:/ssd/media";
        fsType = "nfs";
        options = [
          "nfsvers=4"
          "soft"
          "timeo=30"
          "noauto"
          "x-systemd.automount"
        ];
      };

      boot.loader.systemd-boot.enable = true;
      boot.loader.efi.canTouchEfiVariables = true;
      boot.kernelPackages = pkgs.linuxPackages_latest;
      boot.kernel.sysctl = {
        "vm.unprivileged_userfaultfd" = 1;
      };

      security.pam.loginLimits = [
        {
          domain = "*";
          type = "soft";
          item = "memlock";
          value = "unlimited";
        }
        {
          domain = "*";
          type = "hard";
          item = "memlock";
          value = "unlimited";
        }
      ];

      networking.hostName = "nixos";
      networking.networkmanager.enable = true;
      networking.networkmanager.wifi.powersave = false;

      services.printing.enable = true;
      services.avahi = {
        enable = true;
        nssmdns4 = true;
        openFirewall = true;
      };

      services.udev.packages = [ pkgs.dolphin-emu ];

      time.timeZone = "Asia/Tokyo";
      i18n.defaultLocale = "en_US.UTF-8";
      i18n.extraLocaleSettings = {
        LC_ADDRESS = "ja_JP.UTF-8";
        LC_IDENTIFICATION = "ja_JP.UTF-8";
        LC_MEASUREMENT = "ja_JP.UTF-8";
        LC_MONETARY = "ja_JP.UTF-8";
        LC_NAME = "ja_JP.UTF-8";
        LC_NUMERIC = "ja_JP.UTF-8";
        LC_PAPER = "ja_JP.UTF-8";
        LC_TELEPHONE = "ja_JP.UTF-8";
        LC_TIME = "ja_JP.UTF-8";
      };

      services.xserver.xkb = {
        layout = "jp";
        variant = "";
      };

      hardware.bluetooth = {
        enable = true;
        powerOnBoot = true;
        settings = {
          General = {
            Enable = "Source,Sink,Media,Socket";
            Experimental = true;
            FastConnectable = true;
          };
          Policy.AutoEnable = true;
        };
      };

      users.users.sean = {
        isNormalUser = true;
        description = "sean";
        extraGroups = [
          "networkmanager"
          "wheel"
        ];
      };

      nixpkgs.config.allowUnfree = true;

      services.desktopManager.cosmic.enable = true;
      services.displayManager.cosmic-greeter.enable = true;
      services.system76-scheduler.enable = true;
      services.flatpak.enable = true;

      system.stateVersion = "25.11";

      home-manager = {
        useGlobalPkgs = true;
        useUserPackages = true;
        backupFileExtension = "backup";
        sharedModules = [
          inputs.nix-flatpak.homeManagerModules.nix-flatpak
        ];
        users.sean =
          {
            config,
            pkgs,
            ...
          }:
          {
            home.username = "sean";
            home.homeDirectory = "/home/sean";
            home.stateVersion = "25.11";

            home.file."games".source = config.lib.file.mkOutOfStoreSymlink "/mnt/data/games";

            home.pointerCursor = {
              gtk.enable = true;
              x11.enable = true;
              name = "Breeze_Light";
              size = 24;
              package = pkgs.kdePackages.breeze;
            };

            home.sessionVariables = {
              XCURSOR_THEME = "Breeze_Light";
              XCURSOR_SIZE = "24";
            };

            gtk.cursorTheme = {
              name = "Breeze_Light";
              size = 24;
            };

            dconf.settings = {
              "org/gnome/desktop/interface" = {
                cursor-theme = "Breeze_Light";
                cursor-size = 24;
              };
            };

            services.flatpak = {
              packages = [ "com.github.tchx84.Flatseal" ];
              remotes = [
                {
                  name = "flathub";
                  location = "https://flathub.org/repo/flathub.flatpakrepo";
                }
              ];
              update.auto = {
                enable = true;
                onCalendar = "weekly";
              };
              overrides.global.Context.filesystems = [ "/nix/store:ro" ];
            };

            programs.nix-index-database.comma.enable = true;

            programs.ssh = {
              enable = true;
              enableDefaultConfig = false;
              matchBlocks = {
                "home-server" = {
                  hostname = "192.168.50.110";
                  user = "sean";
                  identityFile = "~/.ssh/id_ed25519";
                };
                "ai-server" = {
                  hostname = "192.168.50.49";
                  user = "sean";
                  identityFile = "~/.ssh/id_ed25519";
                };
              };
            };

            xdg.configFile."fcitx5/profile".text = ''
              [Groups/0]
              Name=Default
              Default Layout=us
              DefaultIM=mozc

              [Groups/0/Items/0]
              Name=keyboard-us
              Layout=

              [Groups/0/Items/1]
              Name=mozc
              Layout=

              [GroupOrder]
              0=Default
            '';
          };
      };
    };
}
