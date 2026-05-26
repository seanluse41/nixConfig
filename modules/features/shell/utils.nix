{ ... }:
{
  flake.homeModules.utils =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        unzip
        zip
        unrar
        p7zip
        # nix
        nixfmt
        nh
        nil
        nixd
        sops
        age
        nix-tree
        deadnix
        # GPU stuff
        pciutils
        rocmPackages.rocminfo
        rocmPackages.rocm-smi
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
