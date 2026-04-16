{ self, inputs, ... }: {
  flake.homeModules.zsh = { ... }: {
    programs.zsh = {
      enable = true;
      shellAliases = {
        rebuild = "nh home switch ~/nixConfig --configuration seanluse";
        gemma = "llama-server -hf unsloth/gemma-4-26B-A4B-it-GGUF --jinja -c 16384 --host 127.0.0.1 --port 8033 -np 1 --min-p 0.0 --webui-mcp-proxy";
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
      };
    };
  };
}