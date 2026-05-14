{ ... }:
{
  flake.homeModules.mpd =
    { config, ... }:
    {
      services.mpd = {
        enable = true;
        musicDirectory = "${config.home.homeDirectory}/Music";
        extraConfig = ''
          audio_output {
            type "pipewire"
            name "PipeWire Sound Server"
          }
          audio_output {
            type "fifo"
            name "Visualizer"
            path "/tmp/mpd.fifo"
            format "44100:16:2"
          }
        '';
      };

      services.mpdris2.enable = true;
    };
}
