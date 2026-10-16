# ES2-KING WebTelnet（網頁文字終端橋接）

這是 Browser（瀏覽器）到 Original ES2 Telnet（文字終端連線協定）的最小入口，沒有改動 Original mudlib 或 Expansion Canon。

伺服器端先啟動 Neolith 的 `4000:telnet`，再執行：

```sh
cd webtelnet
npm install
npm start
```

預設入口為 `http://127.0.0.1:8080`。Deployment（部署）時 server 優先讀取 Hosting 提供的 `PORT`，監聽 `0.0.0.0:$PORT`；本機可用 `WEBTELNET_PORT`、`ES2_HOST`、`ES2_PORT` 調整。Client 會依目前頁面自動使用 `ws://`／`wss://`，不寫死 localhost。

Health Check（健康檢查）為 `GET /health`。只有 Web service、bridge 與內部 Neolith `127.0.0.1:4000` 都可用時回 HTTP 200。

Neolith `4000` 是內部 port，不得直接對 Internet publish（發布）。完整 Container 與 persistence（持久化）說明見 `M30_DEPLOYMENT_READINESS.md`。本工具不代表目前 Work 臨時環境已公開部署。
