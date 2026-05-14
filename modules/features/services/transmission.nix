{ ... }:
{
  flake.nixosModules.transmission =
    { pkgs, ... }:
    {
      services.transmission = {
        enable = true;
        package = pkgs.transmission_4;
        openFirewall = true;
        group = "users";
        settings = {
          download-dir = "/ssd/media/movies";
          rpc-bind-address = "0.0.0.0";
          rpc-whitelist-enabled = false;
        };
      };
    };
}
