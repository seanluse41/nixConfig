{ inputs, ... }:
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
      webuiAssets = {
        "index.html" = pkgs.fetchurl {
          url = "https://huggingface.co/buckets/ggml-org/llama-ui/resolve/latest/index.html?download=true";
          sha256 = "sha256-PqVtrGlFbswvMa2E2ekSFVrjfyR6JI1/KBB6Ita8SvM=";
        };
        "bundle.js" = pkgs.fetchurl {
          url = "https://huggingface.co/buckets/ggml-org/llama-ui/resolve/latest/bundle.js?download=true";
          sha256 = "sha256-D13SEsm7JzzRTtykB/fTUJiAB1sKnKcjVX1bdYbGDyY=";
        };
        "bundle.css" = pkgs.fetchurl {
          url = "https://huggingface.co/buckets/ggml-org/llama-ui/resolve/latest/bundle.css?download=true";
          sha256 = "sha256-TrHUVuoyZTUcAbWqPXcG0hXR5M78L7cN5Y99cD02wXs=";
        };
        "loading.html" = pkgs.fetchurl {
          url = "https://huggingface.co/buckets/ggml-org/llama-ui/resolve/latest/loading.html?download=true";
          sha256 = "sha256-JQAFfjmrgVGNFrKPXQGfYQe1irtHsqMNM4YtnntwPNw=";
        };
      };

      llama =
        if hostName == "macbook" then
          pkgs.llama-cpp
        else
          inputs.llama-cpp.packages.${pkgs.system}.vulkan.overrideAttrs (old: {
            postConfigure = (old.postConfigure or "") + ''
              mkdir -p tools/ui/dist
              cp ${webuiAssets."index.html"} tools/ui/dist/index.html
              cp ${webuiAssets."bundle.js"} tools/ui/dist/bundle.js
              cp ${webuiAssets."bundle.css"} tools/ui/dist/bundle.css
              cp ${webuiAssets."loading.html"} tools/ui/dist/loading.html
            '';
          });
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
      #device 0: RX6700 XT (12gb)
      #device 1: RX9060 XT (16gb)

      systemd.user.services.gemma = lib.mkIf (hostName == "aiServer") {
        Unit = {
          Description = "Qwen llama.cpp server";
          After = [ "network.target" ];
        };
        Service = {
          ExecStart = "${llama}/bin/llama-server -hf ${consts.models.qwen27b} -c 65536 -fa on -ngl 99 --spec-type draft-mtp --spec-draft-n-max 3 --host 0.0.0.0 --port 8033 --webui-mcp-proxy --jinja --min-p 0.0 -t 8 -tb 8 -ctk q8_0 -ctv q8_0 --kv-unified --no-mmproj";
          Restart = "on-failure";
        };
        Install = {
          WantedBy = [ "default.target" ];
        };
      };
    };
}
