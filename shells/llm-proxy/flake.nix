{
  description = "Local LLM proxy";

  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

  outputs = { nixpkgs, ... }:
    let
      system = "aarch64-darwin";
      pkgs = nixpkgs.legacyPackages.${system};
    in {
      devShells.${system}.default = pkgs.mkShell {
        packages = [ pkgs.nodejs ];
        shellHook = ''
          node ${./llm-proxy.js} &
          LLM_PROXY_PID=$!
          echo "LLM proxy started on http://localhost:3001 (PID $LLM_PROXY_PID)"
          trap "kill $LLM_PROXY_PID" EXIT
        '';
      };
    };
}