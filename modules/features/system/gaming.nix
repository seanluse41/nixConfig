{ self, inputs, ... }: {
  flake.nixosModules.gaming = { pkgs, ... }: {
    programs.steam = {
      enable = true;
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = true;
    };

    programs.gamemode.enable = true;
    programs.gamescope.enable = true;

    hardware.graphics = {
      enable = true;
      enable32Bit = true;
    };

    hardware.steam-hardware.enable = true;
    hardware.xpadneo.enable = true;

    boot.kernelModules = [ "hid_nintendo" "xpad" ];
    boot.kernelParams = [ "usbhid.quirks=0x057e:0x2009:0x80000000" "pcie_aspm=off" ];

    environment.systemPackages = with pkgs; [
      wine-staging
      winetricks
      (heroic.override { extraPkgs = pkgs: [ gamescope ]; })
    ];
  };
}
