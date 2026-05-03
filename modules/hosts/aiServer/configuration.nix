{ self, inputs, ... }:
{
  flake.nixosModules.aiServerConfig =
    { ... }:
    {
      imports = [ self.nixosModules.aiServerHardware ];

      boot.loader.systemd-boot.enable = true;
      boot.loader.efi.canTouchEfiVariables = true;

      networking.hostName = "ai-server";
      networking.networkmanager.enable = true;

      time.timeZone = "Asia/Tokyo";
      i18n.defaultLocale = "en_US.UTF-8";

      users.users.sean = {
        isNormalUser = true;
        extraGroups = [
          "wheel"
          "networkmanager"
        ];
      };

      home-manager = {
        useGlobalPkgs = true;
        useUserPackages = true;
        backupFileExtension = "backup";
        users.sean =
          { ... }:
          {
            home.username = "sean";
            home.homeDirectory = "/home/sean";
            home.stateVersion = "25.11";
          };
      };

      hardware.graphics = {
        enable = true;
        enable32Bit = true;
      };

      services.openssh = {
        enable = true;
        settings.PasswordAuthentication = true;
      };
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

      nix.settings.experimental-features = [
        "nix-command"
        "flakes"
      ];
      nix.settings.auto-optimise-store = true;
      nix.gc = {
        automatic = true;
        dates = "weekly";
        options = "--delete-older-than 7d";
      };

      nixpkgs.config.allowUnfree = true;
      system.stateVersion = "25.11";
    };
}
