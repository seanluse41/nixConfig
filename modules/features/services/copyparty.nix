# modules/features/services/copyparty.nix
{ ... }:
{
  flake.nixosModules.copyparty =
    { ... }:
    {
      services.copyparty = {
        enable = true;
        settings = {
          i = "0.0.0.0";
          p = [ 3923 ];
        };
        accounts = {
          sean.passwordFile = "/run/secrets/copyparty-password";
        };
        volumes = {
          "/" = {
            path = "/home/sean/code/secrets";
            access.A = "sean"; # A = admin (rwda)
          };
        };
      };

      networking.firewall.allowedTCPPorts = [ 3923 ];
    };
}