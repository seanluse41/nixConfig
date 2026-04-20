{ ... }: {
  flake.homeModules.mpv = { ... }: {
    programs.mpv = {
      enable = true;
      config = {
        hwdec = "auto-safe";
        vo = "gpu";
      };
    };
  };
}
