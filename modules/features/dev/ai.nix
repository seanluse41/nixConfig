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
          pkgs.pkgsRocm.llama-cpp.override {
            rocmGpuTargets = [
              "gfx1200"
              "gfx1201"
            ];
          };

      waitForGpus = pkgs.writeShellScript "wait-for-gpus" ''
        for i in $(seq 60); do
          n=$(${pkgs.rocmPackages.rocminfo}/bin/rocminfo 2>/dev/null | ${pkgs.gnugrep}/bin/grep -c '^ *Name: *gfx')
          if [ "$n" -ge 2 ]; then exit 0; fi
          sleep 2
        done
        echo "fewer than 2 ROCm GPUs after 120s" >&2
        exit 1
      '';
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
          Description = "llama.cpp server";
          After = [ "network.target" ];
          StartLimitBurst = 3;
          StartLimitIntervalSec = "0";
        };
        Service = {
          ExecStartPre = "${waitForGpus}";
          ExecStart = "${llama}/bin/llama-server -hf ${consts.models.qwen27b} -c 131072 -ctk q8_0 -ctv q8_0 -ngl 99 --cache-ram 0 --host 0.0.0.0 --port 8033 --webui-mcp-proxy --jinja -t 4 -tb 4 -np 1 --kv-unified --no-mmproj --spec-type draft-mtp --spec-draft-n-max 3 --chat-template-kwargs '{\"reasoning_effort\":\"low\"}'";
          Restart = "on-failure";
          RestartSec = "30s";
          TimeoutStartSec = "300";
          Environment = [
            "ROCR_VISIBLE_DEVICES=0,1"
            "GGML_CUDA_DISABLE_GRAPHS=1"
          ];
          LimitMEMLOCK = "infinity";
        };
        Install = {
          WantedBy = [ "default.target" ];
        };
      };
    };
}