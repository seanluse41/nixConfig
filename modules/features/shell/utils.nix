{ ... }:
{
  flake.homeModules.utils =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        unzip
        zip
        unrar
        # nix
        nixfmt
        nh
        nil
        sops
        age
        nix-tree
        deadnix
        # 
        erdtree
        wget
        htop
        btop
        #
        docker-compose
        claude-code
        android-tools
        flutter
        rustup
        # node
        nodejs
        npm-check-updates
        clang
        stripe-cli
        cargo-tauri
        uv
        git
        gh
        jdk
      ];

      programs.fastfetch = {
        enable = true;
        settings = {
          logo.source = "linux";
          display.separator = ": ";
          modules = [
            "break"
            "title"
            "separator"
            "os"
            "kernel"
            "uptime"
            "packages"
            "cpu"
            "gpu"
            "memory"
            "disk"
          ];
        };
      };
    };
}
