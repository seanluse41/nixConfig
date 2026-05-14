{ ... }:
{
  flake.homeModules.hugo =
    { nixpkgs-hugo, nixpkgs-sass, ... }:
    let
      hugoPkgs = import nixpkgs-hugo { system = "aarch64-darwin"; };
      sassPkgs = import nixpkgs-sass { system = "aarch64-darwin"; };
    in
    {
      home.packages = [
        hugoPkgs.hugo
        sassPkgs.dart-sass
      ];
    };
}
