{ self, inputs, ... }:
{
  flake.nixosConfigurations.aiServer = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    modules = with self.nixosModules; [
      aiServerConfig
      inputs.home-manager.nixosModules.default
      {
        home-manager.extraSpecialArgs = { hostName = "aiServer"; };
        home-manager.users.sean.imports = with self.homeModules; [
          bash
          ai
        ];
      }
    ];
  };
}