{ inputs, ... }:
{
  perSystem =
    { system, ... }:
    {
      devShells.tauri = inputs.tauri-shell.devShells.${system}.default;
    };
}
