{ inputs, ... }:
{
  flake.homeModules.ai =
    { pkgs, lib, hostName, ... }:
    let
      webuiAssets = {
        "index.html" = pkgs.fetchurl {
          url = "https://huggingface.co/buckets/ggml-org/llama-ui/resolve/latest/index.html?download=true";
          sha256 = pkgs.lib.fakeHash;
        };
        "bundle.js" = pkgs.fetchurl {
          url = "https://huggingface.co/buckets/ggml-org/llama-ui/resolve/latest/bundle.js?download=true";
          sha256 = pkgs.lib.fakeHash;
        };
        "bundle.css" = pkgs.fetchurl {
          url = "https://huggingface.co/buckets/ggml-org/llama-ui/resolve/latest/bundle.css?download=true";
          sha256 = pkgs.lib.fakeHash;
        };
        "loading.html" = pkgs.fetchurl {
          url = "https://huggingface.co/buckets/ggml-org/llama-ui/resolve/latest/loading.html?download=true";
          sha256 = pkgs.lib.fakeHash;
        };
      };

      llama =
        if hostName == "macbook"
        then pkgs.llama-cpp
        else inputs.llama-cpp.packages.${pkgs.system}.rocm.overrideAttrs (old: {
          cmakeFlags =
            (builtins.filter (f: builtins.match ".*CMAKE_HIP_ARCHITECTURES.*" f == null) old.cmakeFlags)
            ++ [ "-DCMAKE_HIP_ARCHITECTURES:STRING=gfx1031;gfx1200" ];

          preBuild = (old.preBuild or "") + ''
            mkdir -p ../tools/server/public
            cp ${webuiAssets."index.html"} ../tools/server/public/index.html
            cp ${webuiAssets."bundle.js"} ../tools/server/public/bundle.js
            cp ${webuiAssets."bundle.css"} ../tools/server/public/bundle.css
            cp ${webuiAssets."loading.html"} ../tools/server/public/loading.html
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

      systemd.user.services.gemma = lib.mkIf (hostName == "aiServer") {
        Unit = {
          Description = "Qwen llama.cpp server";
          After = [ "network.target" ];
        };
        Service = {
          ExecStart = "${llama}/bin/llama-server -hf unsloth/Qwen3.6-27B-MTP-GGUF:UD-Q4_K_XL -ngl 99 -c 8192 -fa on -np 1 --spec-type mtp --spec-draft-n-max 2 --host 0.0.0.0 --port 8033 --webui-mcp-proxy";
          Restart = "on-failure";
        };
        Install = {
          WantedBy = [ "default.target" ];
        };
      };
    };
}