# ai.nix
{ ... }:
let
  consts = import ../../../consts.nix;
in
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
        else if hostName == "desktop" then
          pkgs.llama-cpp-vulkan
        else
          pkgs.llama-cpp-rocm;
    in
    {
      home.packages = with pkgs; [
        llama
        llmfit
        stable-diffusion-cpp
        python3Packages.huggingface-hub
      ];

      systemd.user.services.gemma = lib.mkIf (hostName == "aiServer") {
        Unit = {
          Description = "Qwen llama.cpp server";
          After = [ "network.target" ];
        };
        Service = {
          ExecStart = "${llama}/bin/llama-server -hf ${consts.models.qwen35b} -c 131072 -ctk q8_0 -ctv q8_0 -ngl 99 --host 0.0.0.0 --port 8033 --spec-type draft-mtp --spec-draft-n-max 3 --webui-mcp-proxy --jinja -t 4 -tb 4 -np 1 --kv-unified --no-mmproj";
          Restart = "on-failure";
          RestartSec = "30s";
          StartLimitBurst = 3;
          StartLimitIntervalSec = "300s";
          Environment = [
            "HSA_OVERRIDE_GFX_VERSION=12.0.1"
            "ROCR_VISIBLE_DEVICES=0,1"
          ];
          LimitMEMLOCK = "infinity";
        };
        Install = {
          WantedBy = [ "default.target" ];
        };
      };
    };
}