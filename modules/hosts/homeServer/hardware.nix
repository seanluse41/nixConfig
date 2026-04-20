{ ... }:
{
  flake.nixosModules.homeServerHardware =
    {
      config,
      lib,
      modulesPath,
      ...
    }:
    {
      imports = [
        (modulesPath + "/installer/scan/not-detected.nix")
      ];

      boot.initrd.availableKernelModules = [
        "ahci"
        "xhci_pci"
        "usbhid"
        "usb_storage"
        "sd_mod"
        "sdhci_pci"
      ];
      boot.initrd.kernelModules = [ ];
      boot.kernelModules = [ "kvm-intel" ];
      boot.extraModulePackages = [ ];

      fileSystems."/" = {
        device = "/dev/disk/by-uuid/181db0ff-1e8d-4846-bc07-5be85d0b9ef0";
        fsType = "ext4";
      };

      fileSystems."/boot" = {
        device = "/dev/disk/by-uuid/135C-04AE";
        fsType = "vfat";
      };

      fileSystems."/ssd" = {
        device = "/dev/disk/by-uuid/3abd3c47-d49a-4132-8049-246be6a0e61c";
        fsType = "ext4";
      };

      swapDevices = [
        { device = "/dev/disk/by-uuid/4e27be2b-9329-484a-91ba-7f7f81c15db5"; }
      ];

      networking.useDHCP = lib.mkDefault true;
      nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
      hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
    };
}
