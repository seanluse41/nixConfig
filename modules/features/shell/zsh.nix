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
          gemma = "llama-server -hf unsloth/gemma-4-31B-it-qat-GGUF:UD-Q4_K_XL -c 131072 -ctk q8_0 -ctv q8_0 -ngl 99 --host 127.0.0.1 --port 8033 --jinja -np 1 --kv-unified --no-mmproj";
        };
        initContent = ''
          fastfetch
          ulimit -n 65535
          export ANDROID_HOME="/Users/sean/Library/Android/sdk"
          export NDK_HOME="$ANDROID_HOME/ndk/29.0.13113456"
          export PATH="$HOME/.npm-global/bin:$PATH"
        '';
        sessionVariables = {
          EDITOR = "nano";
          SOPS_AGE_KEY_FILE = "${config.xdg.configHome}/sops/age/keys.txt";
        };
      };
    };
}
