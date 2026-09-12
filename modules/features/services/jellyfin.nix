{ ... }:
let
  consts = import ../../../consts.nix;
in
{
  flake.nixosModules.jellyfin =
    { ... }:
    {
      services.jellyfin = {
        enable = true;
        openFirewall = true;
      };

      users.users.jellyfin.extraGroups = [
        "video"
        "render"
      ];
      networking.firewall.allowedTCPPorts = [ consts.ports.jellyfin ];
    };
}
