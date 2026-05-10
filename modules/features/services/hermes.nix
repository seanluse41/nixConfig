{ inputs, ... }: {
  flake.nixosModules.hermesAgent = { config, ... }: {
    imports = [ inputs.hermes-agent.nixosModules.default ];

    sops.secrets."SLACK_BOT_TOKEN" = {};
    sops.secrets."SLACK_APP_TOKEN" = {};
    sops.secrets."SLACK_ALLOWED_USERS" = {};

    sops.templates."hermes-env" = {
      owner = "hermes";
      content = ''
        SLACK_BOT_TOKEN=${config.sops.placeholder."SLACK_BOT_TOKEN"}
        SLACK_APP_TOKEN=${config.sops.placeholder."SLACK_APP_TOKEN"}
        SLACK_ALLOWED_USERS=${config.sops.placeholder."SLACK_ALLOWED_USERS"}
      '';
    };

    services.hermes-agent = {
      enable = true;
      settings = {
        model.default = "aiserver/qwen3";
        model.base_url = "http://192.168.50.49:8033/v1";
        model.api_key = "local";
      };
      environmentFiles = [ config.sops.templates."hermes-env".path ];
      addToSystemPackages = true;
    };
  };
}