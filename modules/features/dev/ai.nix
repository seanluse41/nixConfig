{ ... }:
{
  flake.homeModules.ai = { pkgs, lib, hostName, ... }:
  let
    llama =
      if hostName == "macbook" then pkgs.llama-cpp
      else if hostName == "desktop" then pkgs.llama-cpp-rocm
      else pkgs.llama-cpp;
  in
  {
    home.packages = with pkgs; [
      llmfit
      llama
      stable-diffusion-cpp
    ];

    systemd.user.services.gemma = lib.mkIf (hostName == "homeServer") {
      Unit = {
        Description = "Gemma llama.cpp server";
        After = [ "network.target" ];
      };
      Service = {
        ExecStart = "${llama}/bin/llama-server -hf ggml-org/gemma-4-E2B-it-GGUF --jinja -c 0 --host 0.0.0.0 --port 8033 -np 1 --min-p 0.0 --webui-mcp-proxy";
        Restart = "on-failure";
      };
      Install = {
        WantedBy = [ "default.target" ];
      };
    };
  };
}