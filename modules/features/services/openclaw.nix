{ inputs, ... }: {
  flake.homeModules.openclaw =
    { pkgs, lib, ... }:
    {
      imports = [
        inputs.nix-openclaw.homeManagerModules.openclaw
      ];

      programs.openclaw = {
        enable = true;
        config = {
          gateway = {
            mode = "local";
            auth.tokenFile = "/run/secrets/openclaw-gateway-token";
          };
          llm = {
            name = "ai-server";
            type = "openai-compatible";
            baseUrl = "http://192.168.50.49:8033/v1";
            model = "qwen3";
            timeoutMs = 60000;
          };
          channels.line = {
            channelAccessTokenFile = "/run/secrets/line-channel-access-token";
            channelSecretFile = "/run/secrets/line-channel-secret";
            allowFrom = [ ];
          };
        };
      };
    };
}