{ ... }:
{
  flake.homeModules.ai =
    {
      pkgs,
      lib,
      hostName,
      ...
    }:
    let
      llama = if hostName == "macbook" then pkgs.llama-cpp else pkgs.llama-cpp-rocm;
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
          Description = "Gemma llama.cpp server";
          After = [ "network.target" ];
        };
        Service = {
          ExecStart = "${llama}/bin/llama-server -m /home/sean/models/gemma-4-31B-it-Q6_K.gguf -ngl 99 -fa on -c 4096 -np 1 --no-mmproj --host 0.0.0.0 --port 8033";
          Restart = "on-failure";
        };
        Install = {
          WantedBy = [ "default.target" ];
        };
      };
    };
}
