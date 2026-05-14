{ ... }:
let
  consts = import ../../../consts.nix;
in
{
  flake.homeModules.bash =
    { config, ... }:
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
          gemma = "llama-server -hf unsloth/gemma-4-31B-it-GGUF --jinja -c 8192 --host 0.0.0.0 --port 8033 -np 1 --min-p 0.0 --webui-mcp-proxy --no-mmproj --no-mmap -t 8 -tb 8";
          rebuildAiServer = "nh os switch ~/nixConfig -H aiServer";
          aiServer = "ssh ${consts.user}@${consts.network.aiServer}";
        };
        sessionVariables = {
          SOPS_AGE_KEY_FILE = "${config.xdg.configHome}/sops/age/keys.txt";
          CARGO_HOME = "${config.xdg.dataHome}/cargo";
          RUSTUP_HOME = "${config.xdg.dataHome}/rustup";
          npm_config_cache = "${config.xdg.cacheHome}/npm";
        };
initExtra = ''
  fastfetch
  export PATH="$NPM_CONFIG_PREFIX/bin:$PATH"
'';
      };
    };
}
