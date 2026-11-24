{ inputs, ... }:
let
  consts = import ../../../consts.nix;
  repo = "/home/sean/nixConfig";
in

{
  flake.nixosModules.hermesAgent =
    { config, lib, pkgs, ... }:
    let
      ws = "/var/lib/hermes/workspace";
      # `hermes-rebuild "commit message"`: stage, then hand off to the root unit.
      rebuildCmd = pkgs.writeShellApplication {
        name = "hermes-rebuild";
        runtimeInputs = [ pkgs.git ];
        text = ''
          [ $# -eq 1 ] || { echo 'usage: hermes-rebuild "commit message"' >&2; exit 2; }
          cd ${repo}
          git add -A # flakes ignore untracked files
          if git diff --cached --quiet; then echo "nothing to rebuild" >&2; exit 1; fi
          printf '%s\n' "$1" > ${ws}/rebuild-msg
          exec ${config.systemd.package}/bin/systemctl start --no-block hermes-rebuild.service
        '';
      };
    in
    {
      imports = [ inputs.hermes-agent.nixosModules.default ];

      sops.secrets."SLACK_BOT_TOKEN" = { };
      sops.secrets."SLACK_APP_TOKEN" = { };
      sops.secrets."SLACK_ALLOWED_USERS" = { };
      sops.secrets."line-channel-access-token" = { };
      sops.secrets."line-channel-secret" = { };
      sops.secrets."LINE_ALLOWED_USERS" = { };

      sops.templates."hermes-env" = {
        owner = "sean";
        content = ''
          SLACK_BOT_TOKEN=${config.sops.placeholder."SLACK_BOT_TOKEN"}
          SLACK_APP_TOKEN=${config.sops.placeholder."SLACK_APP_TOKEN"}
          SLACK_ALLOWED_USERS=${config.sops.placeholder."SLACK_ALLOWED_USERS"}
          LINE_CHANNEL_ACCESS_TOKEN=${config.sops.placeholder."line-channel-access-token"}
          LINE_CHANNEL_SECRET=${config.sops.placeholder."line-channel-secret"}
          LINE_ALLOWED_USERS=${config.sops.placeholder."LINE_ALLOWED_USERS"}
          LINE_HOME_CHANNEL=Ud032eceead707c6f0d708bed4318fb9e
          LINE_PUBLIC_URL=https://home-server.tail2a5164.ts.net
        '';
      };

      # The upstream hermes-agent module hardcodes 2770 (setgid + group-
      # writable) on all hermes state dirs, via tmpfiles rules AND via the
      # hermes-agent-setup activation script (chmod 2770). The gateway's
      # control-socket permission check rejects a group-writable HERMES_HOME
      # unless the group is the user's private group named after the user —
      # here it is "users", so cron dispatch fails with
      # unsafe_control_permissions. Force 2750 (no group write):
      # mkBefore so these `d` rules come FIRST in 00-nixos.conf — for
      # duplicate `d` lines systemd-tmpfiles applies the FIRST one and
      # ignores later duplicates ("Duplicate line for path ... ignoring").
      systemd.tmpfiles.rules = lib.mkBefore [
        "Z /var/lib/hermes - sean users - -"
        "d /var/lib/hermes 2750 sean users - -"
        "d /var/lib/hermes/.hermes 2750 sean users - -"
        "d /var/lib/hermes/workspace 2750 sean users - -"
        "d /var/lib/hermes/.hermes/cron 2750 sean users - -"
        "d /var/lib/hermes/.hermes/sessions 2750 sean users - -"
        "d /var/lib/hermes/.hermes/logs 2750 sean users - -"
        "d /var/lib/hermes/.hermes/memories 2750 sean users - -"
        "d /var/lib/hermes/.hermes/plugins 2750 sean users - -"
      ];

      # Defense in depth: if the upstream activation script (chmod 2770) runs
      # after systemd-tmpfiles at boot, it would undo the 2750 rules above.
      # Run after it and force 2750 again.
      system.activationScripts."hermes-state-modes" =
        lib.stringAfter [ "hermes-agent-setup" ] ''
          chmod 2750 /var/lib/hermes /var/lib/hermes/.hermes /var/lib/hermes/workspace
          chmod 2750 /var/lib/hermes/.hermes/cron /var/lib/hermes/.hermes/sessions \
            /var/lib/hermes/.hermes/logs /var/lib/hermes/.hermes/memories \
            /var/lib/hermes/.hermes/plugins
        '';

      services.hermes-agent = {
        enable = true;
        user = "sean";
        group = "users";
        createUser = false;
        settings = {
          model = {
            default = "${consts.models.qwen27b}";
            provider = "custom";
            base_url = "http://192.168.50.49:8033/v1";
            api_key = "local";
          };
          custom_providers = [
            {
              name = "aiServer";
              base_url = "http://192.168.50.49:8033/v1";
              model = "${consts.models.qwen27b}";
            }
          ];
          gateway.platforms.line.enabled = true;
          display = {
            interim_assistant_messages = false;
            platforms.line.tool_progress = "off";
          };
        };
        environmentFiles = [ config.sops.templates."hermes-env".path ];
        addToSystemPackages = true;
        workingDirectory = ws; # required for `documents`
        extraPackages = [ rebuildCmd pkgs.cowsay ];
        documents."AGENTS.md" = ''
          ## NixOS rebuilds
          Repo: ${repo}. `git pull` first so flake.lock matches main.
          1. Edit files. Do not run git add or git commit yourself.
          2. Write what you did and what to verify to ${ws}/HANDOFF.md.
          3. Run: hermes-rebuild "commit message"
             It stages, rebuilds and restarts you. It commits only if the rebuild succeeds.
          4. NEVER push to master — all changes go through a PR. The service's commit sits
             on local master (ahead of origin). After "rebuild ok":
             git branch -f hermes/<slug> master && git push origin hermes/<slug>
             gh pr create --base master --head hermes/<slug> --title "..." --body "<what changed + what to verify>"
             Close any earlier unmerged hermes/* PR whose commits are now included in the new branch.
             Tell Sean the PR number. Do NOT reset local master — it stays ahead until Sean
             merges; the next `git pull` fast-forwards.
          5. At the start of every session, if HANDOFF.md exists: read it and check ${ws}/rebuild.log.
             If it ends with "rebuild ok", the change is committed: verify the units, make sure
             the PR exists (create it if not), tell Sean, delete HANDOFF.md.
             If it failed, fix the error and run hermes-rebuild again, or discard with
             `git restore --staged --worktree .`.
        '';
        extraDependencyGroups = [ "messaging" ];
      };

      networking.firewall.allowedTCPPorts = [ 8646 ];

      # Sandbox is ProtectSystem=strict; let Hermes write to the config repo.
      systemd.services.hermes-agent.serviceConfig.ReadWritePaths = [ repo ];

      # gh auth: my HOME is /var/lib/hermes, so gh by default reads
      # /var/lib/hermes/.config/gh — which goes stale whenever Sean refreshes
      # auth from an SSH session (HOME=/home/sean). Point gh at sean's config
      # dir so one auth refresh covers both of us. (Read-only for me under
      # ProtectSystem=strict; that's fine — refreshes happen from SSH.)
      systemd.services.hermes-agent.serviceConfig.Environment = [
        "GH_CONFIG_DIR=/home/sean/.config/gh"
      ];

      # --- Hermes-triggered rebuilds -------------------------------------
      # root may read sean's clone (enable=true required — without it the
      # module writes no /etc/gitconfig and safe.directory is a silent no-op)
      programs.git.enable = true;
      programs.git.config.safe.directory = [ repo ];

      # Separate root service: outlives hermes-agent restarts during activation.
      systemd.services.hermes-rebuild = {
        description = "nixos-rebuild switch, triggered by Hermes";
        restartIfChanged = false; # don't kill the rebuild if it changes this unit
        path = [
          config.nix.package
          pkgs.git
          pkgs.jq
          pkgs.nixos-rebuild
          pkgs.util-linux
        ];
        serviceConfig = {
          Type = "oneshot";
          StandardOutput = "append:${ws}/rebuild.log";
        };
        # set -e: the commit only runs if the rebuild succeeded
        # path: (not the bare path) so nix uses the path fetcher, not the git
        # fetcher — the git fetcher hits root's dubious-ownership check on
        # sean's clone and fails (libgit2 error 7) even with safe.directory.
        #
        # DRAIN GATE (2026-11-24): the switch restarts the hermes-agent unit,
        # which can kill the gateway MID-TURN — in flight replies never get
        # delivered to the user (lost a real LINE message on 2026-11-24).
        # The gateway has a built-in quiesce contract (gateway/drain_control.
        # py): writing {HERMES_HOME}/.drain_request.json makes it refuse NEW
        # turns while in-flight turns run to completion (process stays up),
        # and while the marker exists it re-persists active_agents to
        # gateway_state.json every ~1s. So: write the marker, wait until
        # active_agents == 0 (all turns/cron/API work flushed, replies
        # delivered), THEN switch. The gate must live in the SERVICE, not in
        # the hermes-rebuild wrapper — the wrapper runs inside my turn, and
        # blocking it until active_agents==0 would deadlock (my turn can't
        # end until the wrapper returns). No "epoch" field in the marker:
        # the contract is lenient, presence-only markers are honoured.
        # After the switch, REMOVE the marker: a unit restart keeps the same
        # instantiation epoch (PID 1 unchanged), so the NEW gateway would
        # otherwise honour the stale marker and refuse turns for up to an
        # hour (the NS-570/#85433 hazard).
        script = ''
          HH=/var/lib/hermes/.hermes
          if [ -r $HH/gateway.pid ] && kill -0 "$(cat $HH/gateway.pid)" 2>/dev/null; then
            echo "drain: requesting quiesce (waiting for active_agents=0, up to 15m)"
            printf '{"action":"drain","requested_at":"%s","principal":"hermes-rebuild","suppress_notification":true}\n' \
              "$(date -Is)" > $HH/.drain_request.json
            a=1
            for i in $(seq 1 180); do
              a=$(jq -r '.active_agents // 0' $HH/gateway_state.json 2>/dev/null || echo 0)
              if [ "$a" = "0" ]; then break; fi
              sleep 5
            done
            if [ "$a" = "0" ]; then
              echo "drain: gateway quiesced (active_agents=0), safe to switch"
            else
              echo "drain: WARN — still active (active_agents=$a) after 15m, proceeding anyway"
            fi
          else
            echo "drain: gateway not running, skipping quiesce"
          fi
          echo "=== $(date -Is) ==="
          nixos-rebuild switch --flake path:${repo}#homeServer
          rm -f $HH/.drain_request.json
          runuser -l sean -c '${pkgs.git}/bin/git -C ${repo} commit -q -F ${ws}/rebuild-msg'
          echo "=== rebuild ok ==="
        '';
      };

      # Let sean (Hermes) start exactly that one unit, no sudo needed.
      security.polkit.extraConfig = ''
        polkit.addRule(function (action, subject) {
          if (action.id == "org.freedesktop.systemd1.manage-units" &&
              action.lookup("unit") == "hermes-rebuild.service" &&
              subject.user == "sean") {
            return polkit.Result.YES;
          }
        });
      '';
    };
}