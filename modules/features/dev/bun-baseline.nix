{ pkgs ? import <nixpkgs> {} }:

pkgs.stdenv.mkDerivation {
  pname = "bun-baseline";
  version = "1.3.13";

  src = pkgs.fetchurl {
    url = "https://github.com/oven-sh/bun/releases/download/bun-v1.3.13/bun-linux-x64-baseline.zip";
    sha256 = "0l67xlql0fwdz1xy71sjdxrnjprz49d0mb6s0l10js3h58lj92lx";
  };

  nativeBuildInputs = [ pkgs.unzip pkgs.patchelf ];

  unpackPhase = "unzip $src";

  installPhase = ''
    mkdir -p $out/bin
    cp bun-linux-x64-baseline/bun $out/bin/bun
    chmod +x $out/bin/bun
    patchelf --set-interpreter ${pkgs.glibc}/lib/ld-linux-x86-64.so.2 $out/bin/bun
  '';
}