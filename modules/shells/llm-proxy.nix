{ inputs, ... }:
{
  perSystem = { system, ... }: {
    devShells.llm-proxy = inputs.llm-proxy-shell.devShells.${system}.default;
  };
}