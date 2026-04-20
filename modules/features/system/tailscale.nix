{ ... }: {
  flake.nixosModules.tailscale = { ... }: {
    services.tailscale.enable = true;
    networking.firewall.trustedInterfaces = [ "tailscale0" ];
    services.resolved.enable = true;
  };
}
