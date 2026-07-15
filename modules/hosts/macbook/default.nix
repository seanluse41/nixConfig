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
      hugo
      #devPackages
      utils
      aws
      ai
      (
        { config, lib, ... }:
        {
          home.username = "seanluse";
          home.homeDirectory = "/Users/seanluse";
          home.stateVersion = "25.05";
          programs.home-manager.enable = true;

          sops = {
            defaultSopsFile = "${self}/secrets/secrets.yaml";
            age.keyFile = "/Users/seanluse/.config/sops/age/keys.txt";
            secrets.GITHUB_TOKEN = { };
            templates."nix-access-tokens.conf".content = ''
              access-tokens = github.com=${config.sops.placeholder.GITHUB_TOKEN}
            '';
          };

          xdg.configFile."nix/nix.conf".text = ''
            experimental-features = nix-command flakes
            max-jobs = auto
            cores = 0
            !include ${config.sops.templates."nix-access-tokens.conf".path}
          '';

          # Workaround for nix-community/home-manager#6342 — darwin fonts
          # module's onChange references a package broken by nixpkgs removing
          # apple_sdk_11_0. onChange is types.lines (concatenates regardless
          # of priority), so mkForce on it alone doesn't skip evaluation.
          # Disabling the whole file entry does.
          home.file."Library/Fonts/.home-manager-fonts-version".enable = lib.mkForce false;
        }
      )
    ];
  };
}