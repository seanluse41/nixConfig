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
      llama =
        if hostName == "macbook" then
          pkgs.llama-cpp
        else if hostName == "desktop" || hostName == "aiServer" then
          pkgs.llama-cpp-rocm
        else
          pkgs.llama-cpp;
    in
    {
      home.packages = with pkgs; [
        llmfit
        llama
        stable-diffusion-cpp
      ];

      systemd.user.services.gemma = lib.mkIf (hostName == "aiServer") {
        Unit = {
          Description = "Gemma llama.cpp server";
          After = [ "network.target" ];
        };
        Service = {
          ExecStart = "${llama}/bin/llama-server -hf unsloth/gemma-4-26B-A4B-it-GGUF --jinja -c 16384 --host 0.0.0.0 --port 8033 -np 1 --min-p 0.0 --webui-mcp-proxy --no-mmproj --no-mmap";
          Restart = "on-failure";
        };
        Install = {
          WantedBy = [ "default.target" ];
        };
      };
    };
}