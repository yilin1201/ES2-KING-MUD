import http from "node:http";

const port = Number(process.env.PORT || process.env.WEBTELNET_PORT || 8080);
const request = http.get({ host: "127.0.0.1", port, path: "/health", timeout: 4000 }, response => {
  let body = "";
  response.setEncoding("utf8");
  response.on("data", chunk => { body += chunk; });
  response.on("end", () => {
    try {
      const status = JSON.parse(body);
      process.exit(response.statusCode === 200 && status.web && status.bridge && status.neolith ? 0 : 1);
    } catch {
      process.exit(1);
    }
  });
});
request.on("timeout", () => request.destroy(new Error("health timeout")));
request.on("error", () => process.exit(1));
