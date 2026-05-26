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

      #ai server:
      #intel skylake i5
      #8gb ddr4 ram
      #asusrock z270 exteme 4
      #device 0: RX9070 XT (16gb)
      #device 1: RX9060 XT (16gb)
      #device 2: RX6700 XT (12gb)

      systemd.user.services.gemma = lib.mkIf (hostName == "aiServer") {
        Unit = {
          Description = "Qwen llama.cpp server";
          After = [ "network.target" ];
        };
        Service = {
          ExecStart = "${llama}/bin/llama-server -hf ${consts.models.qwen27b} -c 65536 -fa on -ngl 99 --spec-type draft-mtp --spec-draft-n-max 3 --host 0.0.0.0 --port 8033 --webui-mcp-proxy --jinja --min-p 0.0 -t 8 -tb 8 -ctk q8_0 -ctv q8_0 -np 2 --kv-unified --no-mmproj";
          Restart = "on-failure";
        };
        Install = {
          WantedBy = [ "default.target" ];
        };
      };
    };
}