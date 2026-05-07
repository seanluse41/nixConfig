{ ... }:
{
  flake.homeModules.ai =
    {
      pkgs,
      lib,
      hostName,
      inputs,
      ...
    }:
    let
      llamaFlake = inputs.llama-cpp.packages.${pkgs.system};
      llama =
        if hostName == "macbook" then
          pkgs.llama-cpp
        else if hostName == "desktop" then
          llamaFlake.rocm
        else if hostName == "aiServer" then
          llamaFlake.rocm
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
          ExecStart = "${llama}/bin/llama-server -hf unsloth/Qwen3.6-35B-A3B-GGUF:Q5_K_M --jinja -c 32768 --host 0.0.0.0 --port 8033 -np 3 --min-p 0.0 --webui-mcp-proxy --no-mmproj --no-mmap -t 8 -tb 8";
          Restart = "on-failure";
        };
        Install = {
          WantedBy = [ "default.target" ];
        };
      };
    };
}
