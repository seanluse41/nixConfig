# modules/features/system/gpu-tuning.nix
{ ... }:
{
  flake.nixosModules.gpuTuning =
    { ... }:
    {
      hardware.amdgpu.overdrive.enable = true;
      services.lact.enable = true;
    };
}