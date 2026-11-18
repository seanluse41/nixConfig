{ ... }:
let
  consts = import ../../../consts.nix;
in
{
  flake.nixosModules.immich =
    {
      config,
      lib,
      pkgs,
      ...
    }:
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
        settings = {
          General = {
            Interval = 30;
            Layout = "single";
            ShowClock = true;
            ShowProgressBar = false;
            ShowPhotoDate = false;
            ShowImageDesc = false;
            ShowPeopleDesc = false;
            ShowTagsDesc = false;
            ShowAlbumName = false;
            ShowImageLocation = false;
          };
          Accounts = [
            {
              ImmichServerUrl = "http://localhost:${toString consts.ports.immich}";
              ApiKeyFile = config.sops.secrets.immichframe-api-key.path;
              Albums = [ "1f34a32a-5b68-4ce5-abe7-12b3c0ce37ff" ];
              ShowVideos = true;
            }
          ];
        };
      };

      systemd.services.immichframe = {
        after = [ "immich-server.service" ];
        wants = [ "immich-server.service" ];
        serviceConfig.ExecStart = lib.mkForce "${config.services.immichframe.package}/bin/ImmichFrame.WebApi --urls=http://0.0.0.0:${toString consts.ports.immichFrame}";
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