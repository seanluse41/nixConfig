{ ... }:
{
  flake.homeModules.devPackages =
    { pkgs, lib, ... }:
    {
      home.packages =
        with pkgs;
        [
          godot
        ]
        ++ lib.optionals (!pkgs.stdenv.isDarwin) [
          android-studio
          blender
        ];
    };
}
