{ ... }:
{
  flake.homeModules.kintone =
    { pkgs, ... }:
    let
      version = "1.19.1";
      platform =
        if pkgs.stdenv.isDarwin then
          {
            url = "https://github.com/kintone/cli-kintone/releases/download/v${version}/cli-kintone_v${version}_macos.zip";
            sha256 = "sha256-vLAU4c79kWq4WtF9PaF/kwj8kMxoaC4KeotD0rodBIc=";
            binary = "cli-kintone-macos/cli-kintone";
          }
        else
          {
            url = "https://github.com/kintone/cli-kintone/releases/download/v${version}/cli-kintone_v${version}_linux.zip";
            sha256 = "sha256-fijV8FVH9O4UhkrW6VnpCR0B31mNFubzzcotEb60S8M=";
            binary = "cli-kintone-linux/cli-kintone";
          };
      unwrapped = pkgs.stdenvNoCC.mkDerivation {
        pname = "cli-kintone-unwrapped";
        inherit version;
        src = pkgs.fetchurl {
          inherit (platform) url sha256;
        };
        nativeBuildInputs = [ pkgs.unzip ];
        unpackPhase = "unzip $src";
        installPhase = ''
          mkdir -p $out/bin
          cp ${platform.binary} $out/bin/cli-kintone
          chmod +x $out/bin/cli-kintone
        '';
      };
      cli-kintone =
        if pkgs.stdenv.isDarwin then
          unwrapped
        else
          pkgs.buildFHSEnv {
            name = "cli-kintone";
            targetPkgs = p: [ p.stdenv.cc.cc.lib ];
            runScript = "${unwrapped}/bin/cli-kintone";
          };
    in
    {
      home.packages = [ cli-kintone ];
    };
}
