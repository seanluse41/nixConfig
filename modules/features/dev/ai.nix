{ inputs, ... }:
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
          inputs.llama-cpp.packages.${pkgs.system}.rocm.overrideAttrs (old: {
            cmakeFlags =
              (builtins.filter (f: builtins.match ".*CMAKE_HIP_ARCHITECTURES.*" f == null) old.cmakeFlags)
              ++ [ "-DCMAKE_HIP_ARCHITECTURES:STRING=gfx1031;gfx1200" ];

            preConfigure = (old.preConfigure or "") + ''
              mkdir -p tools/server/public
              echo "<html></html>" > tools/server/public/index.html
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
