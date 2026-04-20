{ ... }: {
  flake.nixosModules.borgBackup = { pkgs, ... }: let
    pi256 = "192.168.50.191";
    user = "sean";
    ssdPushUrl = "http://localhost:3001/api/push/7A0I8FgFnTB40XNRkEG93OfpxOVhKHow";
    piPushUrl = "http://localhost:3001/api/push/P24iryj91s7X4bN57ZvVrbMzA2prL7b1";
  in {
    environment.systemPackages = with pkgs; [ borgbackup ];

    services.borgbackup.jobs."immich-to-ssd" = {
      paths = [ "/var/lib/immich-pictures" ];
      repo = "/ssd/backups/immich";
      startAt = "weekly";
      compression = "zstd,3";
      encryption.mode = "none";
      prune.keep.weekly = 4;
      postHook = ''
        LOG_MSG="Backup completed at $(date)"
        echo "$LOG_MSG" >> /var/log/borg-backup.log
        ${pkgs.curl}/bin/curl -fsS -m 10 --retry 3 "${ssdPushUrl}?status=up&msg=$LOG_MSG" || true
      '';
    };

    services.borgbackup.jobs."immich-to-pi" = {
      paths = [ "/var/lib/immich-pictures" ];
      repo = "${user}@${pi256}:/home/${user}/immich-backup";
      startAt = "monthly";
      compression = "zstd,3";
      encryption.mode = "none";
      prune.keep.monthly = 3;
      postHook = ''
        LOG_MSG="Pi backup completed at $(date)"
        echo "$LOG_MSG" >> /var/log/borg-backup.log
        ${pkgs.curl}/bin/curl -fsS -m 10 --retry 3 "${piPushUrl}?status=up&msg=$LOG_MSG" || true
      '';
    };
  };
}