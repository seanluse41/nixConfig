{ ... }:
{
  flake.homeModules.ai =
    {
      pkgs,
      lib,
      hostName,
      ...
    }:
    let
      llama = if hostName == "macbook" then pkgs.llama-cpp else pkgs.llama-cpp-rocm;
    in
    {
      home.packages = with pkgs; [
        llama
        llmfit
        stable-diffusion-cpp
        python3Packages.huggingface-hub
      ];

      programs.codex = {
        enable = true;
        settings = {
          model_providers.local = {
            name = "local llama.cpp";
            base_url = "http://192.168.50.49:8033/v1";
            wire_api = "responses";
          };
          profiles.local = {
            model_provider = "local";
            model = "local";
          };
        };
      };

      systemd.user.services.gemma = lib.mkIf (hostName == "aiServer") {
        Unit = {
          Description = "Gemma llama.cpp server";
          After = [ "network.target" ];
        };
        Service = {
          ExecStart = "${llama}/bin/llama-server -hf unsloth/Qwen3.6-35B-A3B-GGUF:Q5_K_M --jinja -c 32768 --host 0.0.0.0 --port 8033 -np 2 --min-p 0.0 --webui-mcp-proxy --no-mmproj --no-mmap -t 8 -tb 8";
          Restart = "on-failure";
        };
        Install = {
          WantedBy = [ "default.target" ];
        };
      };
    };
}
