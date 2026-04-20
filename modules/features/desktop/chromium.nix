{ ... }: {
  flake.homeModules.chromium = { pkgs, ... }: {
    programs.chromium = {
      enable = true;
      package = pkgs.ungoogled-chromium;
      commandLineArgs = [
        "--enable-features=VaapiVideoDecoder"
        "--disable-features=UseChromeOSDirectVideoDecoder"
      ];
      extensions = [
        { id = "pnmaklegiibbioifkmfkgpfnmdehdfan"; } # 10ten Japanese Reader
        { id = "cjpalhdlnbpafiamejdnhcphjbkeiagm"; } # uBlock Origin
        { id = "mnjggcdmjocbbbhaepdhchncahnbgone"; } # SponsorBlock
        { id = "nngceckbapebfimnlniiiahkandclblb"; } # Bitwarden
        { id = "ophjlpahpchlmihnnnihgmmeilfjmjjc"; } # LINE
      ];
    };
  };
}