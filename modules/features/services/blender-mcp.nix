# modules/features/services/blender-mcp.nix
{ ... }:
let
  consts = import ../../../consts.nix;
in
{
  flake.homeModules.blenderMcp =
    { pkgs, config, ... }:
    {
      systemd.user.services.blenderMcp = {
        Unit = {
          Description = "Blender MCP Server";
          After = [ "network.target" ];
        };
        Service = {
          ExecStart = "${pkgs.uv}/bin/uv --directory ${config.home.homeDirectory}/code/ai/blender_mcp/mcp run blender-mcp --transport http --port ${toString consts.ports.blenderMcp}";
          Restart = "on-failure";
          WorkingDirectory = "${config.home.homeDirectory}/code/ai/blender_mcp";
          Environment = [ "UV_PYTHON=${pkgs.python3}/bin/python3" ];
        };
        Install = {
          WantedBy = [ "default.target" ];
        };
      };
    };
}
