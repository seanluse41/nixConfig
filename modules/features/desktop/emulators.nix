{ ... }:
{
  flake.homeModules.emulators =
    { pkgs, nixpkgs-master, ... }:
    let
      masterPkgs = import nixpkgs-master {
        inherit (pkgs) system;
        config.allowUnfree = true;
      };
    in
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
        masterPkgs.dusklight
      ];

      services.flatpak.packages = [
        "org.duckstation.DuckStation"
        "com.snes9x.Snes9x"
      ];
    };
}