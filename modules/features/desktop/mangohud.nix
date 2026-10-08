{ ... }:
{
  flake.homeModules.mangohud =
    { ... }:
    {
      programs.mangohud = {
        enable = true;
        settings = {
          gpu_stats = true;
          gpu_temp = true;
          cpu_stats = true;
          fps = true;
          frametime = true;
          frame_timing = true;
          text_outline = true;
        };
      };
    };
}