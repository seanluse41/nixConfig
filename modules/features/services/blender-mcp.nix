# modules/features/services/blender-mcp.nix
{ ... }:
{
  flake.homeModules.blenderMcp =
    { pkgs, config, ... }:
    {
      systemd.user.services.blender-mcp = {
        Unit = {
          Description = "Blender MCP Server";
          After = [ "network.target" ];
        };
        Service = {
          ExecStart = "${pkgs.uv}/bin/uv --directory ${config.home.homeDirectory}/code/ai/blender_mcp/mcp run blender-mcp --transport http --port 9191";
          Restart = "on-failure";
          WorkingDirectory = "${config.home.homeDirectory}/code/ai/blender_mcp";
        };
        Install = {
          WantedBy = [ "default.target" ];
        };
      };
    };
}