{ self, inputs, ... }:
{
  flake.homeConfigurations."seanluse" = inputs.home-manager.lib.homeManagerConfiguration {
    pkgs = import inputs.nixpkgs {
      system = "aarch64-darwin";
      config.allowUnfree = true;
    };
    extraSpecialArgs = {
      inherit self inputs;
      nixpkgs-hugo = inputs.nixpkgs-hugo;
      nixpkgs-sass = inputs.nixpkgs-sass;
      hostName = "macbook";
    };
    modules = with self.homeModules; [
      inputs.mac-app-util.homeManagerModules.default
      inputs.sops-nix.homeManagerModules.sops
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
      {
        home.username = "seanluse";
        home.homeDirectory = "/Users/sean";
        home.stateVersion = "25.05";
        programs.home-manager.enable = true;
        sops = {
          defaultSopsFile = "${self}/secrets/secrets.yaml";
          age.keyFile = "/Users/sean/.config/sops/age/keys.txt";
        };
        home.packages = with inputs.nixpkgs.legacyPackages.aarch64-darwin; [
          age
          sops
          nerd-fonts.jetbrains-mono
        ];
      }
    ];
  };
}
