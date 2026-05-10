{ inputs, ... }: {
  flake.nixosModules.hermesAgent = { config, ... }: {
    imports = [ inputs.hermes-agent.nixosModules.default ];

    services.hermes-agent = {
      enable = true;
      settings = {
        model.default = "aiserver/qwen3";
        model.base_url = "http://192.168.50.49:8033/v1";
        model.api_key = "local";
      };
      environmentFiles = [ config.sops.secrets."hermes-env".path ];
      addToSystemPackages = true;
    };

    sops.secrets."hermes-env" = {
      owner = "hermes";
      template = ''
        SLACK_BOT_TOKEN=${config.sops.placeholder."SLACK_BOT_TOKEN"}
        SLACK_APP_TOKEN=${config.sops.placeholder."SLACK_APP_TOKEN"}
        SLACK_ALLOWED_USERS=${config.sops.placeholder."SLACK_ALLOWED_USERS"}
      '';
    };

    sops.secrets."SLACK_BOT_TOKEN" = {};
    sops.secrets."SLACK_APP_TOKEN" = {};
    sops.secrets."SLACK_ALLOWED_USERS" = {};
  };
}