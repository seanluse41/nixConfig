{
  description = "Tauri development environment";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs =
    { nixpkgs, ... }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      devShells.${system}.default = pkgs.mkShell {
        nativeBuildInputs = with pkgs; [
          pkg-config
          gobject-introspection
          nodejs
        ];

        buildInputs = with pkgs; [
          at-spi2-atk
          atkmm
          cairo
          gdk-pixbuf
          glib
          gtk3
          harfbuzz
          librsvg
          libsoup_3
          pango
          webkitgtk_4_1
          openssl
          desktop-file-utils
        ];

        shellHook = ''
          export NPM_CONFIG_PREFIX="$PWD/.npm-packages"
          export PATH="$NPM_CONFIG_PREFIX/bin:$PATH"

          if [ ! -f ".npm-packages/.installed" ]; then
            npm install -g create-tauri-app
            touch .npm-packages/.installed
          fi
        '';
      };
    };
}
