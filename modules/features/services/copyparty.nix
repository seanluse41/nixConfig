{ ... }:
{
  flake.nixosModules.copyparty =
    { config, pkgs, ... }:
    let
      configFile = pkgs.writeText "copyparty.conf" ''
        [global]
        i: 0.0.0.0
        p: 3923

        [accounts]
        sean: {{password-sean}}

        [/]
        /home/sean/secrets
        accs:
          A: sean
      '';
    in
    {
      sops.secrets.copyparty-password.owner = "copyparty";

      users.users.copyparty = {
        isSystemUser = true;
        group = "copyparty";
      };
      users.groups.copyparty = {};

      systemd.services.copyparty = {
        description = "copyparty file server";
        wantedBy = [ "multi-user.target" ];
        preStart = ''
          install -m 600 ${configFile} /run/copyparty/copyparty.conf
          ${pkgs.replace-secret}/bin/replace-secret \
            '{{password-sean}}' \
            '${config.sops.secrets.copyparty-password.path}' \
            /run/copyparty/copyparty.conf
        '';
        serviceConfig = {
          ExecStart = "${pkgs.copyparty}/bin/copyparty -c /run/copyparty/copyparty.conf";
          RuntimeDirectory = "copyparty";
          RuntimeDirectoryMode = "0700";
          User = "copyparty";
          Group = "copyparty";
          Restart = "on-failure";
        };
      };

      networking.firewall.allowedTCPPorts = [ 3923 ];
    };
}