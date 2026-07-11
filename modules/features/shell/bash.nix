{ ... }:
let
  consts = import ../../../consts.nix;
in
{
  flake.homeModules.bash =
    { config, hostName, ... }:
    {
      programs.bash = {
        enable = true;
        shellAliases = {
          rebuild = "nh os switch ~/nixConfig -H ${hostName}";
          homeServer = "ssh ${consts.user}@${consts.network.homeServer}";
          photoFrame = "ssh ${consts.user}@${consts.network.photoFrame}";
          pi-hole = "ssh ${consts.user}@${consts.network.piHole}";
          raspi256 = "ssh ${consts.user}@${consts.network.pi256}";
          ssd = "cd /mnt/data/";
          tauriShell = "nix develop ~/nixConfig#tauri";
          tree = "erd -H .";
          gemma = "llama-server -hf ${consts.models.gemma31b} -c 16384 -fa on -ngl 99 --host 0.0.0.0 --port 8033 --webui-mcp-proxy --jinja --min-p 0.0 -t 8 -tb 8 -ctk q8_0 -ctv q8_0 --kv-unified --no-mmproj";
          qwen = "llama-server -hf ${consts.models.qwen35b} -c 16384 -fa on -ngl 99 --spec-type draft-mtp --spec-draft-n-max 3 --host 0.0.0.0 --port 8033 --webui-mcp-proxy --jinja --min-p 0.0 -t 8 -tb 8 -ctk q8_0 -ctv q8_0 --kv-unified --no-mmproj";
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
