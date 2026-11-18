{ ... }:
let
  consts = import ../../../consts.nix;
in
{
  flake.nixosModules.immich =
    { config, pkgs, ... }:
    {
      services.immich = {
        enable = true;
        host = "0.0.0.0";
        port = consts.ports.immich;
        mediaLocation = "/var/lib/immich-pictures";
        accelerationDevices = null;
        database.enable = true;
        database.createDB = true;
        environment = {
          PUBLIC_LOGIN_PAGE_MESSAGE = "ルース家写真";
          LOG_LEVEL = "log";
        };
      };

      sops.secrets.immichframe-api-key = { };

      services.immichframe = {
        enable = true;
        port = consts.ports.immichFrame;
        settings.Accounts = [
          {
            ImmichServerUrl = "http://localhost:${toString consts.ports.immich}";
            ApiKeyFile = config.sops.secrets.immichframe-api-key.path;
          }
        ];
      };

      users.users.immich.extraGroups = [
        "video"
        "render"
      ];
      environment.systemPackages = with pkgs; [ immich-cli ];
      networking.firewall.allowedTCPPorts = [
        consts.ports.immich
        consts.ports.immichFrame
      ];
    };
}
