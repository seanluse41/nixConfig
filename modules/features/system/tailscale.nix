{ ... }:
{
  flake.nixosModules.tailscale =
    { lib, pkgs, hostName ? null, ... }:
    let
      isDesktop = hostName == "desktop";
    in
    {
      services.tailscale.enable = true;
      networking.firewall.trustedInterfaces = [ "tailscale0" ];
      services.resolved.enable = true;

      services.tailscale.extraSetFlags = lib.mkIf isDesktop [ "--operator=sean" ];

      systemd.user.services.tailscale-systray = lib.mkIf isDesktop {
        description = "Tailscale systray";
        wantedBy = [ "graphical-session.target" ];
        partOf = [ "graphical-session.target" ];
        after = [ "graphical-session.target" ];
        serviceConfig = {
          ExecStart = "${pkgs.tailscale}/bin/tailscale systray";
          Restart = "on-failure";
        };
      };
    };
}