# M30 Deployment Readiness（M30 部署就緒）

驗證日期：2026-09-17  
Branch：`build/original-es2-races-phase2`  
本輪起始 Head：`7c4de909a44130ce0dff808f9ff30b0184307056`

本文件屬於 M30 Closure（M30 缺口收斂），不建立 M31。Original ES2 保存來源沒有為部署而修改；部署映像只在獨立 Runtime 套用 ES2-KING Expansion overlay（擴充覆蓋層）。

本文件遵守 `ES2_CN_STANDARD.md`：英文技術名詞、指令與狀態第一次出現時，必須附繁體中文名稱與在 ES2-KING 的白話用途。

## 1. Runtime architecture（執行架構）

`Chrome / Edge → HTTPS / WSS → 0.0.0.0:$PORT → Web Client + WebSocket/Telnet Bridge → 127.0.0.1:4000 → Neolith → ES2-KING`

- Public Web Port（公開網頁連接埠）：Hosting 注入的 `$PORT`，預設 `8080`。
- Internal Neolith Port（內部遊戲連接埠）：`4000`。
- `Dockerfile` 只宣告 `8080`，沒有 `EXPOSE 4000`；部署時也禁止把 host port 映射至 `4000`。
- HTTPS（加密網頁連線）由 Hosting reverse proxy（反向代理）終結；瀏覽器會依頁面協定自動選擇 `wss://` 或本機開發用 `ws://`。

## 2. Build（建置）與 Start（啟動）

Build 中文為「建置」，用途是把原始程式轉換成可執行程式。Start 中文為「啟動」，用途是真正啟動 Neolith Driver（MUD 遊戲執行引擎）與 WebSocket/Telnet Bridge（瀏覽器與文字終端的轉接橋梁）。

Container Build（容器建置）固定 Original ES2 commit `cc45c06af4852380e5148dad3c9d53ff06854f2c`，並由其 submodule（子模組）取得 Neolith：

```sh
docker build -t es2-king-alpha .
docker run --rm -p 8080:8080 \
  -e PORT=8080 \
  -v es2-king-save:/var/lib/es2-king/data \
  es2-king-alpha
```

- `docker build` 中文為「建立 Docker 容器映像檔」；用途是把 ES2-KING、Neolith、Web Client 與 Bridge 打包成可部署映像檔。
- `docker run` 中文為「啟動 Docker 容器」；用途是實際啟動剛建立的 ES2-KING 執行環境。
- `-p 8080:8080` 中文為「連接埠映射」；用途是把主機 Web 連接埠送入容器，沒有公開 Neolith `4000`。
- `-v es2-king-save:/var/lib/es2-king/data` 中文為「持久磁碟掛載」；用途是讓玩家與 KING 存檔在容器重啟後仍保留。

不可加入 `-p 4000:4000`。Hosting-independent（不綁平台）啟動入口為 `scripts/start_es2_king_web.sh`；它依序準備持久資料、啟動真實 Neolith、等待 Telnet listener，最後以前景程序啟動 bridge。

## 3. Web（網頁服務）／WSS（加密 WebSocket）／Health Check（健康檢查）

- `webtelnet/server.mjs` 優先使用 `$PORT` 並監聽 `0.0.0.0`。
- Client 以目前頁面的 protocol／host 組成 `/mud` WebSocket URL；HTTPS 頁面自動使用 WSS（加密 WebSocket）。
- Browser reconnect（瀏覽器自動重連）採 1～10 秒退避，不需寫死 host。
- `GET /health` 回傳 `{ web, bridge, neolith }`；只有 bridge 能連到 Neolith `:4000` 時才回 HTTP 200，否則 HTTP 503。
- Health response 不包含帳密、Token、Save Data 或環境秘密。

## 4. Persistence Map（資料持久化對照表）

| 類型 | Runtime path | 性質 | 部署處理 |
|---|---|---|---|
| Account／登入帳號 | `mudlib/data/login/<首字母>/<id>.o` | Mutable Persistent Data（可變持久資料） | 位於 `$ES2_SAVE_DIR` |
| Character／角色 | `mudlib/data/user/<首字母>/<id>.o` | Mutable Persistent Data | 位於 `$ES2_SAVE_DIR` |
| Mail／郵件 | `mudlib/data/mail/<首字母>/<id>.o` | Mutable Persistent Data | 位於 `$ES2_SAVE_DIR` |
| Daemon／字典等狀態 | `mudlib/data/*.o` 與未來子目錄 | Mutable Persistent Data | 整個 `mudlib/data` 一併持久化 |
| KING Account | `mudlib/data/login/k/king.o` | Mutable Persistent Data | 位於 `$ES2_SAVE_DIR/login/k` |
| KING Character | `mudlib/data/user/k/king.o` | Mutable Persistent Data | 位於 `$ES2_SAVE_DIR/user/k` |
| M28／M29 Expansion state | KING／玩家 character save 內的 `dbase.es2_king` mapping（資料表） | Mutable Persistent Data | 隨 `user/<id>.o` 保存 |
| LPC／Canon／房間／指令 | `mudlib/**/*.c` | Immutable Game Files（不可變遊戲程式） | 包在 image，不放玩家 volume |
| 編譯 cache | `mudlib/bin` | 可重建暫存 | 不要求持久化 |
| Runtime log | `mudlib/log` | 可拋棄診斷輸出 | 不視為玩家存檔；Hosting 可另接 log collector |

`scripts/prepare_es2_persistence.sh` 會把 image seed（初始資料）只補入空 volume，然後把 `mudlib/data` symlink（符號連結）至 `$ES2_SAVE_DIR`。既有檔案採 no-clobber（不覆寫）處理，restart／redeploy 時不會用 seed 蓋掉角色進度。

## 5. Persistence（資料持久化）狀態

- Persistence Path Test（資料持久化路徑測試）：PASS（測試通過）；已驗證 seed（初始資料）、symlink（符號連結）與第二次初始化後角色檔仍保留。
- 有正確掛載 Persistent Volume 時，Runtime 架構可在 restart／redeploy 後沿用存檔。
- 沒有 volume（儲存空間）的平台檔案系統可能在重啟或重新部署時清除。因此未掛 disk（持久磁碟）時，狀態必須是 `PERSISTENCE-HOSTING-LIMITATION（主機無持久磁碟，因此重新部署後玩家存檔可能消失）`，不得宣稱 Hosting persistence PASS（主機資料持久化測試通過）。
- `render.yaml` 刻意沒有建立 disk，也沒有 Secret（機密資料）或 KING credential（KING 登入憑證）；若所選 Render 方案沒有免費 persistent disk，玩家存檔只能維持上述限制狀態。

## 6. Verification Status（驗證狀態）

| 驗證 | 結果 |
|---|---|
| Deployment Static Gate（部署靜態檢查關卡） | LOCAL PASS（本機測試通過） |
| Web Bridge Syntax（網頁橋接程式語法檢查） | LOCAL PASS（本機測試通過） |
| Persistence Path Test（資料持久化路徑測試） | LOCAL PASS（本機測試通過） |
| Existing Linux Neolith Driver Build（既有 Linux 驅動程式建置） | 既有 PASS（測試通過）；本輪未改 Driver／mudlib |
| Equivalent Linux Deployment Start（等效 Linux 部署啟動） | LOCAL PASS（本機測試通過） |
| `/health` Health Check（健康檢查） | LOCAL PASS（本機測試通過） |
| Deployment Smoke Test（部署冒煙測試，用最短流程確認服務可到達 ES2 登入提示） | LOCAL PASS（本機測試通過） |
| Docker／Container Build（Docker／容器建置） | `CONTAINER-ENVIRONMENT-LIMITATION（容器執行環境限制，不代表程式失敗）`：Work 沒有 Docker、Podman 或 Buildah，未冒充 PASS（測試通過） |
| GitHub Actions（GitHub 自動測試） | `ACTIONS-INFRA-BLOCKED（GitHub 自動測試受到帳號／基礎設施限制，並非程式測試失敗）`；沒有 rerun（重新執行） |
| M30 Browser Playable Journey（瀏覽器可玩流程） | `ENVIRONMENT-LIMITATION（執行環境限制，不代表程式本身失敗）`；沒有公開 URL（網址），仍非 PASS（測試通過） |

等效 Linux 測試使用既有真實 Neolith binary（可執行檔）與整合 Runtime（遊戲執行環境），透過本輪正式 start script（啟動腳本）啟動，並非 Mock（模擬程式）。Container（容器）定義已完成，但仍須在有 Docker 的外部 builder（建置環境）真正執行一次 image build（映像檔建置），才可把 Container status（容器狀態）改成 PASS（測試通過）。

## 7. Render Compatibility（Render 部署相容性）

Repository（程式碼儲存庫）已具備 `render.yaml`、`Dockerfile`、`0.0.0.0:$PORT`（公開 Web 服務監聽位置）、`/health` 與同源 WSS 路徑，狀態為 `RENDER DEPLOYMENT READY（Render 部署設定已準備）`。本輪沒有建立 Render Service（Render 執行服務）、沒有購買資源、沒有填信用卡，也沒有建立付費 disk。

部署前仍必須：

1. 在 Render 實際完成 Docker build；
2. 確認所選方案當下可用且不產生費用；
3. 若沒有免費 persistent volume，接受 `PERSISTENCE-HOSTING-LIMITATION`，或改用已有持久磁碟的零成本／既有主機；
4. 取得真實 HTTPS URL 後重跑 Browser Journey，才可宣告 `M30 BROWSER PLAYABLE PASS`。

## 8. Security Boundary（安全權限邊界）

- Internet 只進入 HTTPS/WSS Web port；Neolith `4000` 不公開。
- KING 授權仍由 Original password authentication（密碼驗證）＋精確 Account ID＋Expansion authorization 決定。
- Container、文件、測試與 environment template 沒有 KING 密碼。
- KING 只有 Game Authority（遊戲權限），不會取得 Host Shell、OS Root、GitHub Token、Secrets 或 Cloud Credentials。

## 9. Known Limitations（已知限制）

1. Work 缺少容器引擎，Container Build 尚未實跑。
2. Repository 尚未實際部署到外部 Hosting，沒有可交付的公開 URL。
3. 未掛 Persistent Volume 的 Hosting 無法保證存檔跨 redeploy 保留。
4. `M30 BROWSER PLAYABLE PASS` 維持未成立；只有 protocol／bridge／真實 prompt smoke PASS。
5. PR #13 必須保持 Open／Not Merged；本輪不建立 M31。
