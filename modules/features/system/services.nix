{ ... }: {
  flake.nixosModules.desktopServices = { ... }: {
    services.flaresolverr = {
      enable = true;
      openFirewall = true;
    };

    services.mullvad-vpn.enable = true;
  };
}
