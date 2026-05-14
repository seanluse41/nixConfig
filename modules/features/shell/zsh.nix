{ ... }: {
  flake.homeModules.zsh = { config, ... }: {
    programs.zsh = {
      enable = true;
      shellAliases = {
        rebuild = "home-manager -- switch --flake ~/nixConfig#seanluse";
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