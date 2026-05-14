{ ... }:
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
      networking.firewall.allowedTCPPorts = [ 8096 ];
    };
}
