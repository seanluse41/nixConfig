{ ... }:
{
  flake.homeModules.communications =
    { config, pkgs, ... }:
    {
      programs.thunderbird = {
        enable = true;
        profiles."default".isDefault = true;
      };

      home.sessionVariables = {
        THUNDERBIRD_HOME = "${config.xdg.configHome}/thunderbird";
      };

      accounts.email.accounts = {
        "gmail" = {
          primary = true;
          address = "seanluse41@gmail.com";
          realName = "Sean";
          imap = {
            host = "imap.gmail.com";
            port = 993;
            tls.enable = true;
          };
          smtp = {
            host = "smtp.gmail.com";
            port = 465;
            tls.enable = true;
          };
          userName = "seanluse41@gmail.com";
          thunderbird = {
            enable = true;
            profiles = [ "default" ];
            settings = id: {
              "mail.server.server_${id}.authMethod" = 10;
              "mail.smtpserver.smtp_${id}.authMethod" = 10;
            };
          };
        };

        "chudstop" = {
          address = "chudstop@cock.li";
          realName = "admin";
          imap = {
            host = "mail.cock.li";
            port = 993;
            tls.enable = true;
          };
          smtp = {
            host = "mail.cock.li";
            port = 465;
            tls.enable = true;
          };
          userName = "chudstop@cock.li";
          thunderbird = {
            enable = true;
            profiles = [ "default" ];
          };
        };
      };

      home.packages = with pkgs; [
        slack
        zoom-us
      ];
    };
}
