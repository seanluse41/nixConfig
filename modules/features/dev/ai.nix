# ai.nix
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
      config,
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
            preConfigure = (old.preConfigure or "") + ''
              export CCACHE_DIR="/var/cache/ccache"
              export CCACHE_COMPRESS=1
              export CCACHE_UMASK=007
            '';
            CMAKE_C_COMPILER_LAUNCHER = "${pkgs.ccache}/bin/ccache";
            CMAKE_CXX_COMPILER_LAUNCHER = "${pkgs.ccache}/bin/ccache";
          });

      llama-server-vulkan = lib.mkIf (hostName == "aiServer") (
        pkgs.writeShellScriptBin "llama-server-vulkan" ''
          exec ${pkgs.llama-cpp-vulkan}/bin/llama-server "$@"
        ''
      );
    in
    {
      home.packages =
        with pkgs;
        [
          llama
          llmfit
          stable-diffusion-cpp
          python3Packages.huggingface-hub
        ]
        ++ lib.optionals (hostName == "aiServer") [ llama-server-vulkan ];

      #ai server:
      #intel skylake i5
      #8gb ddr4 ram
      #asusrock z270 exteme 4
      #device 0: RX9070 XT (16gb)
      #device 1: RX9060 XT (16gb)
      #device 2: RX6700 xt (12gb) <- currently disabled

      systemd.user.services.gemma = lib.mkIf (hostName == "aiServer") {
        Unit = {
          Description = "Qwen llama.cpp server";
          After = [ "network.target" ];
        };
        Service = {
          ExecStart = "${llama}/bin/llama-server -hf ${consts.models.qwen27b} -c 65536 -ngl 99 --host 0.0.0.0 --port 8033 --spec-type draft-mtp --spec-draft-n-max 3 --webui-mcp-proxy --jinja -t 4 -tb 4 -np 1 --kv-unified --no-mmproj";
          Restart = "on-failure";
          Environment = "HSA_OVERRIDE_GFX_VERSION=12.0.1";
        };
        Install = {
          WantedBy = [ "default.target" ];
        };
      };
    };
}
