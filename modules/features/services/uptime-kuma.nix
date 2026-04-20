{ ... }: {
  flake.nixosModules.uptimeKuma = { pkgs, ... }: {
    services.uptime-kuma = {
      enable = true;
      settings = {
        PORT = "3001";
        UPTIME_KUMA_HOST = "0.0.0.0";
      };
    };

    networking.firewall.allowedTCPPorts = [ 3001 ];

    systemd.services.borg-status-check = {
      description = "Check borg backup status and log";
      serviceConfig = {
        Type = "oneshot";
        ExecStart = pkgs.writeShellScript "borg-status" ''
          BACKUP_LOG="/var/log/borg-backup.log"
          STATUS_FILE="/var/lib/borg-status.txt"
          if [ -f "$BACKUP_LOG" ]; then
            LAST_BACKUP=$(tail -n 1 "$BACKUP_LOG")
            echo "OK - $LAST_BACKUP" > "$STATUS_FILE"
          else
            echo "WARNING - No backup log found" > "$STATUS_FILE"
          fi
        '';
      };
    };

    systemd.timers.borg-status-check = {
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = "hourly";
        Persistent = true;
      };
    };
  };
}