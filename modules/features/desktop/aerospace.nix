{ ... }:
{
  flake.homeModules.aerospace =
    { ... }:
    {
      programs.aerospace = {
        enable = true;
        launchd.enable = true;
        settings = {
          enable-normalization-flatten-containers = true;
          enable-normalization-opposite-orientation-for-nested-containers = true;
          accordion-padding = 30;
          default-root-container-layout = "tiles";
          default-root-container-orientation = "auto";
          key-mapping.preset = "qwerty";

          gaps = {
            inner.horizontal = 12;
            inner.vertical = 16;
            outer.left = 16;
            outer.bottom = 16;
            outer.top = 16;
            outer.right = 24;
          };

          mode.main.binding = {
            cmd-h = "layout tiles horizontal vertical";
            cmd-left = "focus left";
            cmd-down = "focus down";
            cmd-up = "focus up";
            cmd-right = "focus right";
            cmd-shift-left = "move left";
            cmd-shift-down = "move down";
            cmd-shift-up = "move up";
            cmd-shift-right = "move right";
            cmd-shift-minus = "resize smart -50";
            cmd-shift-equal = "resize smart +50";
            cmd-1 = "workspace 1";
            cmd-2 = "workspace 2";
            cmd-3 = "workspace 3";
            cmd-4 = "workspace 4";
            cmd-5 = "workspace 5";
            cmd-6 = "workspace 6";
            cmd-7 = "workspace 7";
            cmd-8 = "workspace 8";
            cmd-9 = "workspace 9";
            cmd-shift-1 = "move-node-to-workspace 1";
            cmd-shift-2 = "move-node-to-workspace 2";
            cmd-shift-3 = "move-node-to-workspace 3";
            cmd-shift-4 = "move-node-to-workspace 4";
            cmd-shift-5 = "move-node-to-workspace 5";
            cmd-shift-6 = "move-node-to-workspace 6";
            cmd-shift-7 = "move-node-to-workspace 7";
            cmd-shift-8 = "move-node-to-workspace 8";
            cmd-shift-9 = "move-node-to-workspace 9";
            cmd-enter = "exec-and-forget open -a Terminal";
            cmd-esc = "mode service";
          };

          mode.service.binding = {
            esc = [
              "reload-config"
              "mode main"
            ];
            r = [
              "flatten-workspace-tree"
              "mode main"
            ];
            f = [
              "layout floating tiling"
              "mode main"
            ];
            backspace = [
              "close-all-windows-but-current"
              "mode main"
            ];
            alt-shift-h = [
              "join-with left"
              "mode main"
            ];
            alt-shift-j = [
              "join-with down"
              "mode main"
            ];
            alt-shift-k = [
              "join-with up"
              "mode main"
            ];
            alt-shift-l = [
              "join-with right"
              "mode main"
            ];
          };

          workspace-to-monitor-force-assignment = {
            "6" = "secondary";
            "7" = "secondary";
            "8" = "secondary";
            "9" = "secondary";
          };

          on-window-detected = [
            {
              check-further-callbacks = true;
              "if".app-id = "com.apple.iphonesimulator";
              run = "layout floating";
            }
          ];
        };
      };
    };
}
