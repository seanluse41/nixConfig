{ inputs, ... }:
{
  flake.nixosModules.hermesAgent =
    { config, ... }:
    {
      imports = [ inputs.hermes-agent.nixosModules.default ];

      sops.secrets."SLACK_BOT_TOKEN" = { };
      sops.secrets."SLACK_APP_TOKEN" = { };
      sops.secrets."SLACK_ALLOWED_USERS" = { };
      sops.secrets."line-channel-access-token" = { };
      sops.secrets."line-channel-secret" = { };
      sops.secrets."LINE_ALLOWED_USERS" = { };

      sops.templates."hermes-env" = {
        owner = "hermes";
        content = ''
          SLACK_BOT_TOKEN=${config.sops.placeholder."SLACK_BOT_TOKEN"}
          SLACK_APP_TOKEN=${config.sops.placeholder."SLACK_APP_TOKEN"}
          SLACK_ALLOWED_USERS=${config.sops.placeholder."SLACK_ALLOWED_USERS"}
          LINE_CHANNEL_ACCESS_TOKEN=${config.sops.placeholder."line-channel-access-token"}
          LINE_CHANNEL_SECRET=${config.sops.placeholder."line-channel-secret"}
          LINE_ALLOWED_USERS=${config.sops.placeholder."LINE_ALLOWED_USERS"}
          LINE_PUBLIC_URL=https://home-server.tail2a5164.ts.net
        '';
      };

      systemd.tmpfiles.rules = [
        "Z /var/lib/hermes - hermes hermes - -"
      ];

      services.hermes-agent = {
        enable = true;
        settings = {
          model = {
            default = "unsloth/Qwen3.6-27B-MTP-GGUF:Q5_K_M";
            provider = "custom";
            base_url = "http://192.168.50.49:8033/v1";
            api_key = "local";
          };
          custom_providers = [
            {
              name = "aiServer";
              base_url = "http://192.168.50.49:8033/v1";
              model = "unsloth/Qwen3.6-27B-MTP-GGUF:Q5_K_M";
            }
          ];
          gateway.platforms.line.enabled = true;
          display = {
            interim_assistant_messages = false;
            platforms.line.tool_progress = "off";
          };
        };
        environmentFiles = [ config.sops.templates."hermes-env".path ];
        addToSystemPackages = true;
      };

      users.users.sean.extraGroups = [ "hermes" ];

      networking.firewall.allowedTCPPorts = [ 8646 ];
    };
}
