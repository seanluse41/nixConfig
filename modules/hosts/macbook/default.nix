{ self, inputs, ... }:
{
  flake.darwinConfigurations."seanluse" = inputs.nix-darwin.lib.darwinSystem {
    system = "aarch64-darwin";
    modules = with self.nixosModules; [
      inputs.home-manager.darwinModules.home-manager
      inputs.sops-nix.darwinModules.sops
      inputs.mac-app-util.darwinModules.default
      {
        nixpkgs.config.allowUnfree = true;

        sops = {
          defaultSopsFile = "${self}/secrets/secrets.yaml";
          age.keyFile = "/Users/sean/Library/Application Support/sops/age/keys.txt";
          secrets.GITHUB_TOKEN = { };
        };

        users.users.seanluse.home = "/Users/sean";
        system.primaryUser = "seanluse";
        system.stateVersion = 6;
        system.activationScripts.postActivation.text = ''
  mkdir -p /Users/sean/.config/nix
  echo "access-tokens = github.com=$(cat /run/secrets/GITHUB_TOKEN)" > /Users/sean/.config/nix/nix.conf
'';

        home-manager = {
          useGlobalPkgs = true;
          useUserPackages = true;
          backupFileExtension = "backup";
          extraSpecialArgs = {
            inherit self inputs;
            nixpkgs-hugo = inputs.nixpkgs-hugo;
            nixpkgs-sass = inputs.nixpkgs-sass;
            hostName = "macbook";
          };
          users.seanluse = { ... }: {
            imports = with self.homeModules; [
              aerospace
              starship
              zsh
              kintone
              vscode
              communications
              hugo
              devPackages
              utils
              aws
              ai
            ];
            home.username = "seanluse";
            home.homeDirectory = "/Users/sean";
            home.stateVersion = "25.05";
            programs.home-manager.enable = true;
            home.packages = with inputs.nixpkgs.legacyPackages.aarch64-darwin; [
              age
              sops
              nerd-fonts.jetbrains-mono
            ];
          };
        };
      }
    ];
  };
}