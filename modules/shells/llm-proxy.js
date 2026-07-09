// llm-proxy.js
const http = require("http");
const https = require("https");

const TARGET = "ai1-api.dev.cybozu.xyz";

http.createServer((req, res) => {
  res.setHeader("Access-Control-Allow-Origin", "http://localhost:1313");
  res.setHeader("Access-Control-Allow-Methods", "*");
  res.setHeader("Access-Control-Allow-Headers", "*");
  if (req.method === "OPTIONS") return res.writeHead(200).end();

  const proxy = https.request(
    { host: TARGET, path: `/v1${req.url}`, method: req.method,
      headers: { "content-type": "application/json" } },
    (upstream) => {
      res.writeHead(upstream.statusCode);
      upstream.pipe(res);
    }
  );

  req.pipe(proxy);
  proxy.on("error", (e) => res.writeHead(502).end(e.message));
}).listen(3001, () => console.log("LLM proxy running on http://localhost:3001"));                                             
