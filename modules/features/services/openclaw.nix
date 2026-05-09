{ inputs, ... }:
{
  flake.homeModules.openclaw =
    { pkgs, lib, ... }:
    {
      imports = [
        inputs.nix-openclaw.homeManagerModules.openclaw
      ];

      programs.openclaw = {
        enable = true;
        package = inputs.nix-openclaw.packages.x86_64-linux.openclaw-gateway;
        config = {
          gateway = {
            mode = "local";
            auth.token = "/run/secrets/openclaw-gateway-token";
          };
          models = {
            mode = "merge";
            providers = {
              aiserver = {
                baseUrl = "http://192.168.50.49:8033/v1";
                apiKey = "local";
                api = "openai-completions";
                models = [
                  {
                    id = "qwen3";
                    name = "Qwen3 (AI Server)";
                    reasoning = false;
                    input = [ "text" ];
                    cost = {
                      input = 0;
                      output = 0;
                      cacheRead = 0;
                      cacheWrite = 0;
                    };
                    contextWindow = 32768;
                    maxTokens = 4096;
                  }
                ];
              };
            };
          };
          agents.defaults.model.primary = "aiserver/qwen3";
          channels.line = {
            channelAccessTokenFile = "/run/secrets/line-channel-access-token";
            channelSecretFile = "/run/secrets/line-channel-secret";
            allowFrom = [ ];
          };
        };
      };
    };
}
