{ ... }:
{
  flake.homeModules.mediaPackages =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        yt-dlp
        audacity
        mpc
        kooha
        qbittorrent
        filezilla
        prowlarr
        ani-cli
      ];

      systemd.user.services.prowlarr = {
        Unit = {
          Description = "Prowlarr";
          After = [ "network.target" ];
        };
        Service = {
          ExecStart = "${pkgs.prowlarr}/bin/Prowlarr -nobrowser -data=%h/.config/Prowlarr";
          Restart = "on-failure";
        };
        Install = {
          WantedBy = [ "default.target" ];
        };
      };
    };
}
