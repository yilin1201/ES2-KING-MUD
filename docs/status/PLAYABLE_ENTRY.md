# ES2-KING Browser Playable Entry／瀏覽器可玩入口

## One-click Command／一鍵啟動命令

```bash
bash scripts/start_es2_king_playable.sh
```

用途：重用既有 Neolith Driver、Original ES2 Runtime、ES2-KING Expansion、WebSocket Bridge 與 Web MUD Client；不重新建置 Driver。

## Runtime Status／執行狀態

| 項目 | 實際結果 |
|---|---|
| Neolith Driver／遊戲引擎 | PASS（測試通過） |
| Internal TCP Port／內部文字連線埠 | `127.0.0.1:4000`，PASS（測試通過） |
| WebSocket Bridge／網頁即時連線橋接 | PASS（測試通過） |
| Web MUD Client／網頁遊戲介面 | HTTP 載入與靜態顯示測試 PASS（測試通過） |
| Local Browser URL／本機瀏覽器網址 | `http://127.0.0.1:8080` |
| Original ES2 Login Prompt／登入提示 | PASS（測試通過） |
| WebSocket Runtime Chain／網頁即時連線執行鏈 | Bridge → Neolith → Login Prompt → KING Login，PASS（測試通過） |
| KING Login／KING 登入 | WebSocket E2E（端到端）PASS；受控 Chrome 實機驗收受環境隔離限制 |
| Basic Commands／基本指令 | 經 WebSocket E2E 執行 `look`、`score`、`inventory`、`skills`，均 PASS（測試通過） |
| Local Browser Status／本機瀏覽器狀態 | ENVIRONMENT-LIMITATION（執行環境限制）：Work 受控瀏覽器禁止存取 Runtime namespace 的 `127.0.0.1`，不得冒稱 Browser PASS |
| Primary Public URL／主要公開網址 | `https://es2-king-mud.onrender.com` |
| Primary Render Build／主要部署版本 | `0c260ee1bfb1630016b858ae0e96a68f4eb17900`，與 Branch HEAD 一致 |
| Public HTTPS / WSS／公開加密網頁與即時連線 | PASS（測試通過） |
| Public Race Runtime／公開種族流程 | PASS（測試通過）：Race → Gender → Character → Enter Game |
| Public Device Status／外部裝置狀態 | PENDING（需要 Owner 使用 iPhone Safari 在 Primary URL 最終驗收） |
| Temporary Validation Service／臨時驗證服務 | `es2-king-alpha`：TEMP / UNCHANGED，不是 Primary |

## Architecture／架構

Browser（瀏覽器）→ Web Client（網頁介面）→ WebSocket（網頁雙向即時通訊）→ Bridge（橋接服務）→ `127.0.0.1:4000` → Neolith → ES2-KING。

`127.0.0.1` 是本機位址。Primary Public Runtime 已由 Render 對外提供 HTTPS / WSS，且公開自動測試已完成 Login Prompt、Race、Gender、Character 與 Enter Game。受控環境不能冒充 Owner 的 iPhone Safari，因此 Public Device Acceptance 仍保持 PENDING。
