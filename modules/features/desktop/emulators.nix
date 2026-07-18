{ ... }:
{
  flake.homeModules.emulators =
    { pkgs, nixpkgs-master, ... }:
    {
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
        dusklight
      ];

      services.flatpak.packages = [
        "org.duckstation.DuckStation"
        "com.snes9x.Snes9x"
      ];
    };
}
