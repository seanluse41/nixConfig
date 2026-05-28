{
  flake.nixosModules.ccache =
    { config, ... }:
    {
      programs.ccache = {
        enable = true;
        packageNames = [
          "llama-cpp-rocm"
          "rpcs3"
          "_2ship2harkinian"
          "shipwright"
          "nxengine-evo"
          "easyrpg-player"
          "dusklight"
        ];
      };

      nix.settings.extra-sandbox-paths = [ config.programs.ccache.cacheDir ];

      nixpkgs.overlays = [
        (self: super: {
          ccacheWrapper = super.ccacheWrapper.override {
            extraConfig = ''
              export CCACHE_COMPRESS=1
              export CCACHE_DIR="${config.programs.ccache.cacheDir}"
              export CCACHE_UMASK=007
              export CCACHE_SLOPPINESS=random_seed
              if [ ! -d "$CCACHE_DIR" ]; then
                echo "Run: sudo mkdir -m0770 '$CCACHE_DIR' && sudo chown root:nixbld '$CCACHE_DIR'"
                exit 1
              fi
              if [ ! -w "$CCACHE_DIR" ]; then
                echo "Directory '$CCACHE_DIR' not writable for $(whoami)"
                exit 1
              fi
            '';
          };
        })
      ];
    };
}