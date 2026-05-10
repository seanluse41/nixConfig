{ self, inputs, ... }:
{
  flake.nixosConfigurations.homeServer = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    modules = with self.nixosModules; [
      homeServerConfig
      tailscale
      immich
      borgBackup
      uptimeKuma
      nfs
      jellyfin
      transmission
      inputs.sops-nix.nixosModules.sops
      inputs.home-manager.nixosModules.default
      {
        nixpkgs.overlays = [ inputs.nix-openclaw.overlays.default ];
        nixpkgs.config.permittedInsecurePackages = [
          "openclaw-2026.4.22"
        ];
        sops = {
        defaultSopsFile = "${self}/secrets/secrets.yaml";
        age.keyFile = "/home/sean/.config/sops/age/keys.txt";
          secrets.line-channel-access-token = {
            owner = "sean";
          };
          secrets.line-channel-secret = {
            owner = "sean";
          };
          secrets.openclaw-gateway-token = {
            owner = "sean";
          };
        };

        networking.firewall.allowedTCPPorts = [ 18789 ];

        home-manager.extraSpecialArgs = {
          hostName = "homeServer";
          inherit inputs;
        };
        home-manager.users.sean.imports = with self.homeModules; [
          utils
          bash
          git
        ];
      }
    ];
  };
}
