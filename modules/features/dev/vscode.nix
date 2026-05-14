{ ... }:
{
  flake.homeModules.vscode =
    { pkgs, ... }:
    {
      programs.vscodium = {
        enable = true;
        profiles.default.extensions =
          with pkgs.vscode-extensions;
          [
            dart-code.flutter
            vitaliymaz.vscode-svg-previewer
            tauri-apps.tauri-vscode
            svelte.svelte-vscode
            bradlc.vscode-tailwindcss
            tamasfe.even-better-toml
            redhat.vscode-yaml
            jnoortheen.nix-ide
          ]
          ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
            {
              name = "vscode-kanbn-boards";
              publisher = "samgiz";
              version = "0.14.1";
              sha256 = "sha256-+BIMS5icyEmj1JXKVZmcOfTFI4w/F1zpjbt9ziG7XEk=";
            }
            {
              name = "shades-of-purple";
              publisher = "ahmadawais";
              version = "7.3.6";
              sha256 = "sha256-22ZywGew1Qh4YPi51JWTNQLKuz/nzx/iprUK96DQfYU=";
            }
          ];
        profiles.default.userSettings = {
          "editor.quickSuggestions".strings = "on";
          "workbench.colorTheme" = "Shades of Purple";
          "explorer.confirmDragAndDrop" = false;
          "workbench.startupEditor" = "none";
          "explorer.confirmDelete" = false;
          "svelte.ask-to-enable-ts-plugin" = false;
          "update.showReleaseNotes" = false;
          "editor.stickyScroll.enabled" = false;
          "terminal.integrated.initialHint" = false;
          "git.openRepositoryInParentFolders" = "never";
          "explorer.confirmPasteNative" = false;
          "terminal.integrated.stickyScroll.enabled" = false;
          "redhat.telemetry.enabled" = false;
          "js/ts.updateImportsOnFileMove.enabled" = "always";
          "update.mode" = "none";
        };
      };
    };
}
