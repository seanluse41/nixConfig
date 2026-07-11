{ self, inputs, ... }:
{
  flake.nixosModules.aiServerConfig =
    { pkgs, ... }:
    {
      imports = [
        self.nixosModules.aiServerHardware
        self.nixosModules.tailscale
      ];

      boot.kernelParams = [ "amdgpu.runpm=0" ];
      boot.loader.systemd-boot.enable = true;
      boot.loader.efi.canTouchEfiVariables = true;

      networking.hostName = "ai-server";
      networking.networkmanager.enable = true;
      networking.firewall.allowedTCPPorts = [ 22 80 443 8080 8033 ];

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

      users.users.sean = {
        isNormalUser = true;
        linger = true;
        extraGroups = [ "wheel" "networkmanager" "video" "render" ];
      };

      services.openssh = {
        enable = true;
        settings.PasswordAuthentication = true;
      };

      hardware.graphics = {
        enable = true;
        extraPackages = with pkgs; [
          rocmPackages.clr
          rocmPackages.clr.icd
          mesa
          libdrm
        ];
      };

      hardware.amdgpu.opencl.enable = true;

      systemd.tmpfiles.rules = [
        "L+ /opt/rocm - - - - ${
          pkgs.symlinkJoin {
            name = "rocm-combined";
            paths = with pkgs.rocmPackages; [ rocblas hipblas clr ];
          }
        }"
      ];

      environment.variables = {
        ROCM_TARGET_LIST = "gfx1200,gfx1201,gfx1031";
      };

      security.pam.loginLimits = [
        { domain = "*"; type = "soft"; item = "memlock"; value = "unlimited"; }
        { domain = "*"; type = "hard"; item = "memlock"; value = "unlimited"; }
      ];

      nix.settings = {
        experimental-features = [ "nix-command" "flakes" ];
        max-jobs = "auto";
        cores = 0;
        auto-optimise-store = true;
        extra-sandbox-paths = [ "/var/cache/ccache" ];
        trusted-users = [ "sean" ];
      };

      nix.gc = {
        automatic = true;
        dates = "weekly";
        options = "--delete-older-than 7d";
      };

      home-manager = {
        useGlobalPkgs = true;
        useUserPackages = true;
        backupFileExtension = "backup";
        users.sean = { ... }: {
          home.username = "sean";
          home.homeDirectory = "/home/sean";
          home.stateVersion = "25.11";
        };
      };

      nixpkgs.config.allowUnfree = true;
      system.stateVersion = "25.11";
    };
}