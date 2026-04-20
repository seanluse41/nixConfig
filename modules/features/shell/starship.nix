{ ... }: {
  flake.homeModules.starship = { ... }: {
    programs.starship = {
      enable = true;
      settings = {
        "$schema" = "https://starship.rs/config-schema.json";
        add_newline = true;
        command_timeout = 5000;
        git_branch = {
          format = "\\[[$branch]($style)\\]";
          symbol = "";
        };
        git_status.format = "(\\[[$all_status$ahead_behind]($style)\\])";
        nodejs.format = "\\[[$version]($style)\\]";
        rust.format = "\\[[$version]($style)\\]";
        nix_shell.format = "\\[[$state( \\($name\\))]($style)\\]";
        cmd_duration.format = "\\[[⏱ $duration]($style)\\]";
        time = {
          format = "\\[[$time]($style)\\]";
          disabled = false;
        };
        directory.format = "[$path]($style) ";
      };
    };
  };
}