{ ... }:
let
  masterPkgs = import nixpkgs-master {
    inherit (pkgs) system;
    config.allowUnfree = true;
  };
in
{
  flake.homeModules.emulators =
    { pkgs, ... }:
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
