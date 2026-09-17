# ES2-KING WebTelnet（網頁文字終端橋接）

這是 Browser（瀏覽器）到 Original ES2 Telnet（文字終端連線協定）的最小入口，沒有改動 Original mudlib 或 Expansion Canon。

伺服器端先啟動 Neolith 的 `4000:telnet`，再執行：

```sh
cd webtelnet
npm install
npm start
```

預設入口為 `http://127.0.0.1:8080`。可用 `WEBTELNET_PORT`、`ES2_HOST`、`ES2_PORT` 調整。公開使用時仍需一個可由公司瀏覽器到達、能同時連到 Neolith 的主機，並應以 HTTPS/WSS（加密網頁／加密 WebSocket）反向代理保護帳密。本工具不代表目前 Work 臨時環境已公開部署。
