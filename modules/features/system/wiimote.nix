{ ... }:
{
  flake.nixosModules.wiimote =
    { pkgs, ... }:
    {
      boot.kernelModules = [ "uinput" ];

      services.udev.extraRules = ''
        KERNEL=="uinput", GROUP="input", MODE="0660"
      '';

      users.users.sean.extraGroups = [ "input" ];

      environment.systemPackages = with pkgs; [
        xwiimote
      ];
    };
}
