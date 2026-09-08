{ ... }:
{
  flake.homeModules.aws =
    { pkgs, lib, hostName, ... }:
    {
      home.packages = with pkgs; [
        awscli2
        aws-sam-cli
      ];

      home.activation.awsCredentials = lib.mkIf (hostName != "macbook") (
        lib.hm.dag.entryAfter [ "writeBoundary" ] ''
          mkdir -p ~/.aws
          cat > ~/.aws/credentials << EOF
          [default]
          aws_access_key_id=$(cat /run/secrets/aws-access-key-id)
          aws_secret_access_key=$(cat /run/secrets/aws-secret-access-key)
          EOF
          chmod 600 ~/.aws/credentials
        ''
      );
    };
}