{ self, inputs, ... }:
let
  consts = import ../../../consts.nix;
in
{
  flake.homeModules.bash =
    { ... }:
    {
      programs.bash = {
        enable = true;
        shellAliases = {
          rebuild = "nh os switch ~/nixConfig -H desktop";
          rebuildServer = "nh os switch ~/nixConfig -H homeServer";
          homeServer = "ssh ${consts.user}@${consts.network.homeServer}";
          photoFrame = "ssh ${consts.user}@${consts.network.photoFrame}";
          pi-hole = "ssh ${consts.user}@${consts.network.piHole}";
          raspi256 = "ssh ${consts.user}@${consts.network.pi256}";
          ssd = "cd /mnt/data/";
          tauriShell = "nix develop ~/nixConfig#tauri";
          tree = "erd -H .";
          gemma = "llama-server -hf ggml-org/gemma-4-E2B-it-GGUF --jinja -c 0 --host 127.0.0.1 --port 8033 -np 1 --min-p 0.0 --webui-mcp-proxy -ngl 999";
        };
        sessionVariables = {
          SOPS_AGE_KEY_FILE = "/var/lib/sops-nix/key.txt";
        };
        initExtra = ''
          fastfetch
          export NPM_CONFIG_PREFIX="$HOME/.npm-global"
          export PATH="$NPM_CONFIG_PREFIX/bin:$PATH"
        '';
      };
    };
}
