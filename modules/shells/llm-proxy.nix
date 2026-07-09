{ ... }:
{
  perSystem = { pkgs, ... }: {
    devShells.llm-proxy = pkgs.mkShell {
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