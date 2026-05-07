{ self, inputs, ... }:
{
  flake.nixosConfigurations.aiServer = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    modules = with self.nixosModules; [
      aiServerConfig
      tailscale
      inputs.home-manager.nixosModules.default
      {
        home-manager.extraSpecialArgs = { hostName = "aiServer"; inherit inputs; };
        home-manager.users.sean.imports = with self.homeModules; [
          bash
          ai
          utils
        ];
      }
    ];
  };
}