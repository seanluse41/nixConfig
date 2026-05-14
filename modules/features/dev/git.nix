{ ... }:
{
  flake.homeModules.git =
    { ... }:
    {
      programs.git = {
        enable = true;
        lfs.enable = true;
        settings.user.name = "seanluse41";
        settings.user.email = "seanluse41@gmail.com";
        signing.format = null;
      };

      programs.gh = {
        enable = true;
        gitCredentialHelper.enable = true;
      };
    };
}
