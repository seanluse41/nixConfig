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
      llama =
        if hostName == "macbook" then
          pkgs.llama-cpp
        else
          inputs.llama-cpp.packages.${pkgs.system}.rocm.overrideAttrs (old: {
            cmakeFlags =
              (builtins.filter (f: builtins.match ".*CMAKE_HIP_ARCHITECTURES.*" f == null) old.cmakeFlags)
              ++ [ "-DCMAKE_HIP_ARCHITECTURES:STRING=gfx1031;gfx1200" ];
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
          ExecStart = "${llama}/bin/llama-server -hf ${consts.models.qwen27b} -c 65536 -fa on -np 1 --spec-type ngram-mod,draft-mtp --spec-draft-n-max 2 --host 0.0.0.0 --port 8033 --webui-mcp-proxy --jinja --min-p 0.0 -t 8 -tb 8 -ctk q8_0 -ctv q8_0";
          Restart = "on-failure";
        };
        Install = {
          WantedBy = [ "default.target" ];
        };
      };
    };
}