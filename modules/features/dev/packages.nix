{ ... }:
{
  flake.homeModules.devPackages =
    { pkgs, lib, hostName, ... }:
    {
      home.packages =
        with pkgs;
        [
          godot
        ]
        ++ lib.optionals (hostName != "macbook") [
          android-studio
          blender
        ];
    };
}