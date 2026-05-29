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
              ++ [ "-DCMAKE_HIP_ARCHITECTURES:STRING=gfx1200;gfx1201" ];
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
      #device 0: RX9070 XT (16gb)
      #device 1: RX9060 XT (16gb)

      systemd.user.services.gemma = lib.mkIf (hostName == "aiServer") {
        Unit = {
          Description = "Qwen llama.cpp server";
          After = [ "network.target" ];
        };
        Service = {
          ExecStart = "${llama}/bin/llama-server -hf ${consts.models.qwen27b} -c 65536 -ngl 99 --host 0.0.0.0 --port 8033 --webui-mcp-proxy --jinja -t 8 -tb 8 -np 2 --kv-unified --no-mmproj";
          Restart = "on-failure";
          Environment = "HSA_OVERRIDE_GFX_VERSION=12.0.1";
        };
        Install = {
          WantedBy = [ "default.target" ];
        };
      };
    };
}
