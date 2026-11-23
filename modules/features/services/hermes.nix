{ inputs, ... }:
let
  consts = import ../../../consts.nix;
in

{
  flake.nixosModules.hermesAgent =
    { config, lib, pkgs, ... }:
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

      systemd.tmpfiles.rules = lib.mkBefore [
        "Z /var/lib/hermes - sean users - -"
        "d /var/lib/hermes/.hermes 2750 sean users - -"
      ];

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
        workingDirectory = "/var/lib/hermes/workspace"; # required for `documents`
        documents."AGENTS.md" = ''
          ## NixOS rebuilds
          - Repo: /var/lib/hermes/nixConfig. `git pull` first so flake.lock matches main, then edit and commit.
          - Before rebuilding, write what you did and what to verify to /var/lib/hermes/workspace/HANDOFF.md.
          - Rebuild: /run/current-system/sw/bin/systemctl start --no-block hermes-rebuild.service
            It will restart you. That is expected.
          - At the start of every session, if HANDOFF.md exists: read it, check rebuild.log and the
            relevant units, always report the outcome to Sean via the LINE gateway, then delete HANDOFF.md.
        '';
        extraDependencyGroups = [ "messaging" ];
      };

      networking.firewall.allowedTCPPorts = [ 8646 ];

      # --- Hermes-triggered rebuilds -------------------------------------
      # root may read sean's clone
      programs.git.config.safe.directory = [ "/var/lib/hermes/nixConfig" ];

      # Separate root service: outlives hermes-agent restarts during activation.
      systemd.services.hermes-rebuild = {
        description = "nixos-rebuild switch, triggered by Hermes";
        restartIfChanged = false; # don't kill the rebuild if it changes this unit
        path = [
          config.nix.package
          pkgs.git
          pkgs.nixos-rebuild
        ];
        serviceConfig = {
          Type = "oneshot";
          StandardOutput = "append:/var/lib/hermes/workspace/rebuild.log";
        };
        script = "nixos-rebuild switch --flake /var/lib/hermes/nixConfig#homeServer";
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