{ self, inputs, ... }:
{
  imports = [
    inputs.home-manager.flakeModules.home-manager
  ];

  systems = [ "x86_64-linux" ];

  flake.nixosConfigurations.desktop = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    modules = with self.nixosModules; [
      desktopConfig
      inputs.home-manager.nixosModules.default
      {
        home-manager.extraSpecialArgs = {
          hostName = "desktop";
          inherit (inputs) nixpkgs-master;
        };
        home-manager.users.sean.imports = with self.homeModules; [
          inputs.nix-index-database.homeModules.nix-index
          chromium
          bash
          vscode
          git
          devPackages
          mpd
          ncmpcpp
          mpv
          mediaPackages
          communications
          emulators
          utils
          aws
          kintone
          ai
        ];
      }
    ];
  };
}
