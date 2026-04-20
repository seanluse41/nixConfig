{ ... }: {
  flake.homeModules.emulators = { pkgs, ... }: {
    home.packages = with pkgs; [
      dolphin-emu
      melonds
      pcsx2
      rpcs3
      ryubing
      fceux
      _2ship2harkinian
      shipwright
      nxengine-evo
      easyrpg-player
    ];

    services.flatpak.packages = [
      "org.duckstation.DuckStation"
      "com.snes9x.Snes9x"
    ];
  };
}
