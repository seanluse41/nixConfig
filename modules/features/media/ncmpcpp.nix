{ ... }: {
  flake.homeModules.ncmpcpp = { pkgs, ... }: {
    programs.ncmpcpp = {
      enable = true;
      package = pkgs.ncmpcpp.override { visualizerSupport = true; };
      settings = {
        mpd_host = "localhost";
        mpd_port = 6600;
        visualizer_data_source = "/tmp/mpd.fifo";
        visualizer_output_name = "Visualizer";
        visualizer_in_stereo = "yes";
        visualizer_type = "spectrum";
        visualizer_look = "●●";
        visualizer_spectrum_smooth_look = "no";
        startup_screen = "visualizer";
      };
    };
  };
}
