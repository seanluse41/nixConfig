{ self, inputs, ... }:
{
  flake.nixosModules.homeServerConfig =
    { pkgs, ... }:
    {
      imports = [
        self.nixosModules.homeServerHardware
        inputs.sops-nix.nixosModules.sops
      ];

      boot.loader.systemd-boot.enable = true;
      boot.loader.efi.canTouchEfiVariables = true;

      networking = {
        hostName = "home-server";
        networkmanager.enable = true;
        firewall.allowedTCPPorts = [ 22 80 443 8080 8033 ];
      };

      time.timeZone = "Asia/Tokyo";
      i18n.defaultLocale = "en_US.UTF-8";
      console.keyMap = "jp106";
      services.xserver.xkb.layout = "jp";

      users.users.sean = {
        isNormalUser = true;
        linger = true;
        extraGroups = [ "wheel" "docker" "networkmanager" ];
      };

      hardware.graphics = {
        enable = true;
        extraPackages = with pkgs; [
          intel-media-driver
          intel-compute-runtime
        ];
      };

      virtualisation.docker.enable = true;

      services.openssh = {
        enable = true;
        settings.PasswordAuthentication = true;
      };

      services.journald.extraConfig = ''
        SystemMaxUse=100M
        MaxRetentionSec=3day
      '';

      sops.secrets.GITHUB_TOKEN = {
        owner = "sean";
      };

      nix.settings = {
        experimental-features = [ "nix-command" "flakes" ];
        auto-optimise-store = true;
        extra-sandbox-paths = [ "/var/cache/ccache" ];
        trusted-users = [ "sean" ];
        trusted-public-keys = [
          "desktop:BhUdL4xwaKkc77fe+B7iQulMzkd5VWXSyQKZ2rnGp04="
        ];
      };

      nix.gc = {
        automatic = true;
        dates = "daily";
        options = "--delete-older-than 3d";
      };

      home-manager = {
        useGlobalPkgs = true;
        useUserPackages = true;
        backupFileExtension = "backup";
        users.sean = { ... }: {
          home.username = "sean";
          home.homeDirectory = "/home/sean";
          home.stateVersion = "24.11";
        };
      };

      nixpkgs.config.allowUnfree = true;
      system.stateVersion = "24.11";
    };
}