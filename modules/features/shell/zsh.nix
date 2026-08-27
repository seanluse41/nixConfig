{ ... }:
{
  flake.homeModules.zsh =
    { config, ... }:
    {
      programs.zsh = {
        enable = true;
        shellAliases = {
          rebuild = "home-manager switch --flake ~/nixConfig#seanluse -b backup";
          llm-proxy = "nix develop ~/nixConfig#llm-proxy";
          qwen = "/Users/seanluse/code/llm/llama.cpp/build/bin/llama-server --model /Users/seanluse/code/llm/models/Qwen3.8-27B-UD-Q6_K_M.gguf --ctx-size 16384 --port 9931 --host 127.0.0.1 --jinja --reasoning auto --spec-type draft-mtp --spec-draft-n-max 3 -ngl 99";
        };
        initContent = ''
          fastfetch
          ulimit -n 65535
          export ANDROID_HOME="/Users/sean/Library/Android/sdk"
          export NDK_HOME="$ANDROID_HOME/ndk/29.0.13113456"
          export PATH="$HOME/.npm-global/bin:$PATH"
          export SDKROOT="$(xcrun --show-sdk-path)"
        '';
        sessionVariables = {
          EDITOR = "nano";
          SOPS_AGE_KEY_FILE = "${config.xdg.configHome}/sops/age/keys.txt";
        };
      };
    };
}