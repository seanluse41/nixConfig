{ ... }:
{
  flake.nixosModules.nfs =
    { ... }:
    {
      services.nfs.server = {
        enable = true;
        exports = ''
          /ssd/media 192.168.50.0/24(rw,sync,no_subtree_check,all_squash,anonuid=1000,anongid=1000)
        '';
      };

      networking.firewall.allowedTCPPorts = [
        2049
        111
      ];
      networking.firewall.allowedUDPPorts = [
        2049
        111
      ];
    };
}
