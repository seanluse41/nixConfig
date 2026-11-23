# modules/features/system/amdgpu.nix
{ ... }:
{
  flake.nixosModules.amdgpu =
    { ... }:
    {
      hardware.amdgpu.overdrive.enable = true;
      services.lact.enable = true;
      services.lact.settings = {
        version = 7;
        daemon = {
          log_level = "info";
          admin_groups = [
            "wheel"
            "sudo"
          ];
          disable_clocks_cleanup = false;
        };
        gpus."1002:744C-1002:0E3B-0000:03:00.0" = {
          voltage_offset = -50;
          performance_level = "auto";
        };
      };
    };
}
