{ ... }:
{
  flake.nixosModules.desktopHardware =
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
        "xhci_pci"
        "nvme"
        "ahci"
        "usbhid"
        "usb_storage"
        "sd_mod"
      ];
      boot.initrd.kernelModules = [ ];
      boot.kernelModules = [ "kvm-amd" ];
      boot.extraModulePackages = [ ];

      fileSystems."/" = {
        device = "/dev/mapper/luks-53254e1c-99c1-4a97-a840-6b480f949f34";
        fsType = "ext4";
      };

      boot.initrd.luks.devices."luks-53254e1c-99c1-4a97-a840-6b480f949f34".device =
        "/dev/disk/by-uuid/53254e1c-99c1-4a97-a840-6b480f949f34";

      fileSystems."/boot" = {
        device = "/dev/disk/by-uuid/00F7-1B16";
        fsType = "vfat";
        options = [
          "fmask=0077"
          "dmask=0077"
        ];
      };

      swapDevices = [ ];

      nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
      hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
    };
}
