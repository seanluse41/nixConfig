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
          llamaFlake.rocm.overrideAttrs (old: {
            cmakeFlags =
              (builtins.filter (f: builtins.match ".*CMAKE_HIP_ARCHITECTURES.*" f == null) old.cmakeFlags)
              ++ [ "-DCMAKE_HIP_ARCHITECTURES:STRING=gfx1031;gfx1200" ];
          })
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
          ExecStart = "${llama}/bin/llama-server -hf froggeric/Qwen3.6-27B-MTP-GGUF:Q6_K --spec-type mtp --spec-draft-n-max 3 --jinja -c 32768 --host 0.0.0.0 --port 8033 -np 1 --min-p 0.0 --webui-mcp-proxy --no-mmproj --no-mmap -t 8 -tb 8 -ctk q8_0 -ctv q8_0 -ngl 99";
          Restart = "on-failure";
        };
        Install = {
          WantedBy = [ "default.target" ];
        };
      };
    };
}
