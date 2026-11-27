# M30 Playable Alpha Entry（M30 可遊玩 Alpha 入口）

Branch：`build/original-es2-races-phase2`  
本次重新驗證起始 Head：`473092d54a82ea87f903bd2a4a8130b8520abb67`  
KING Owner 程式／Canon Head（驗收文件更新前）：`eb37f3d4c2d3edb500ea95feb98e1edf92bb04ad`

GitHub Actions（GitHub 自動化測試）因免費額度／US$0 預算無法啟動，狀態僅為 `ACTIONS-INFRA-BLOCKED`；沒有 rerun，也沒有宣稱 Actions PASS。

## 1. M30 PLAYABLE DRIVER PASS

**狀態：PASS。**

- Original ES2 mudlib：`taedlar/es2_mudlib` commit `cc45c06af4852380e5148dad3c9d53ff06854f2c`。
- Neolith Driver（MUD 遊戲執行引擎）：`neolith-1.0.0`，來源 commit `96b33bdad773713769d7af453d5989d76e69ca0a`。
- Runtime：乾淨 Original tree → Expansion overlay → Neolith。
- Driver Build：CMake／Ninja 全新設定及 109 build steps，PASS。
- Driver Boot：PASS；`master object is created successfully`。
- Telnet listener：`127.0.0.1:4000` 實際連線 PASS。
- Original 玩家連線、創角、房間、look、score、inventory、移動、NPC、戰鬥、學習、save、quit、獨立重新連線及 persistence（持久化）已有真正 Driver 證據，不是 Mock（模擬程式）或 Static Test（靜態測試）。

## 2. KING Owner Expansion Canon

`king` 是唯一 `KING / Owner / Creator` 帳號，屬於 ES2-KING Expansion Canon，不是 Original ES2 歷史設定。

授權鏈：

`Original Login` → `Password Authentication（密碼驗證）` → `Account ID = king` → `KING Authorization（KING 授權）` → `Owner / Creator`

Display Name（顯示名稱）不參與授權。遊戲權限層級為：

`KING / Owner / Creator` > `Administrator / Wizard` > `Player` > `NPC`

遊戲權限不會授予 Work Shell、OS Root、GitHub Token、GitHub Secrets、Cloud Credentials 或其他 Infrastructure Authority（基礎設施權限）。

Alpha 密碼僅透過 Original ES2 正常登入系統輸入、驗證及雜湊保存；Repository、程式、文件、Workflow、Commit 與測試 fixture 沒有保存明文密碼。

## 3. KING OWNER PLAYABLE PASS

**狀態：PASS。**

| 真實 Driver 步驟 | 結果 |
|---|---|
| Connect／Account Login／Password Authentication | PLAYABLE PASS |
| KING Authorization／顯示 `(admin)` | PLAYABLE PASS |
| Enter Game／look／score／inventory | PLAYABLE PASS |
| movement／say | PLAYABLE PASS |
| `kingcreate list` | PLAYABLE PASS |
| `kingcreate creation_mark`／inventory | PLAYABLE PASS |
| `kingrealm`／天神殿・無極之境／look | PLAYABLE PASS |
| `kingmartial yijinjing 300` | PLAYABLE PASS：黑級無極境 |
| `kingmartial batian ji` | PLAYABLE PASS |
| `kingcanon huntian 10` | PLAYABLE PASS：玄宇宙 |
| `kingcanon rulai 11` | PLAYABLE PASS：第十一式與阿賴耶識・歸墟神輪 |
| `kingcanon turn 4` | PLAYABLE PASS：破八識 |
| save／quit／relogin | PLAYABLE PASS |
| Relogin 後再次執行 KING command | PLAYABLE PASS |

## 4. KING AUTHORIZATION ISOLATION PASS

**狀態：PASS。**

反向測試建立普通 Player 帳號，Display Name 同樣設定為 `KING`：

- Original Login 顯示權限 `(player)`。
- `score` 顯示不同 Account ID。
- 嘗試 `kingcreate`、`kingrealm`、`kingmartial`、`kingcanon` 全部無法執行。
- 沒有產生物品、移動至神域或寫入 Expansion 武學／Canon 狀態。

授權程式同時要求：interactive（真人互動連線）＋精確 Account ID `king`＋Original admin 權限。一般 Player、同名角色及其他 Administrator 均不能取得 KING 專屬功能。

## 5. Regression（回歸測試）

- KING Owner Authorization Static：PASS。
- M26 Static／Runtime Gate：PASS。
- M27 Static／Runtime Gate：PASS。
- M28 Static／Runtime Gate：PASS。
- M29 Static／Runtime Gate：PASS。
- M30 Runtime Gate：PASS。
- Original 200 級技能上限：保留。
- M28／M29 既定名稱、境界、招式與佛兵：未改寫。
- Original preserved source：未修改；Owner 授權只由 Expansion overlay 套入獨立 Runtime。

## 6. Web Client 與 WebSocket/Telnet Bridge

Repository 的 `webtelnet/` 已完成：

- 黑底文字終端、UTF-8 繁體中文。
- MUD Output（遊戲輸出）。
- Command Input（指令輸入）與 Enter 送出。
- 自動捲動及 WebSocket（網頁雙向通訊）狀態。
- Login／Password／Character Creation 與一般指令均以原始文字流傳送。
- WebSocket → Telnet TCP `127.0.0.1:4000` bridge（橋接服務）。
- Node 語法、套件鎖定及 WebSocket 收到真實 ES2 登入提示：PASS。

Web Entry 與 Original mudlib 分離，沒有修改 Original 保存原始碼。

## 7. Browser Acceptance 與 External Access

`M30 BROWSER PLAYABLE PASS`：**尚未成立。**

第一次以真正 Chrome browser 開啟 Work 本機 Web Client 時，Work 執行環境離線；恢復後再次啟動 Neolith `:4000` 與 WebSocket Bridge `:8080`，兩個本機 listener 均確認可連線，但 Cloud Browser 開啟 `http://127.0.0.1:8080` 明確回報 `ERR_BLOCKED_BY_CLIENT`。這證明 Browser 與 Work Runtime 不共享 localhost；因此仍沒有完整 Browser Journey 證據，不能用 HTML、Static 或 WebSocket 腳本冒充 Browser PASS。

目前狀態：

- Repository Web Client：完成。
- WebSocket/Telnet Bridge：完成，本機協定整合 PASS。
- 真正 Browser 全流程：`ENVIRONMENT-LIMITATION`。
- Owner 外部 Chrome／Edge 公開 URL：不存在，不得虛構。
- Work Public Port／Temporary Public URL／HTTPS forwarding：實際檢查環境與工具後未提供可用端點；未嘗試繞過平台隔離。
- 待完成：一個零成本或既有的公開 Hosting／External Access（主機託管／外部連線）位置，能同時常駐 Neolith 與 bridge，配置 HTTPS/WSS 後重跑 Browser Journey。

沒有購買服務、填入信用卡、提高 GitHub Spending Budget 或啟用付費 Actions。

## 8. PARTIAL／UNKNOWN

- 一般玩家透過任務、師承或戰鬥自然取得 M28／M29 Expansion progression（遊戲進程）：PARTIAL。
- M28／M29 傷害、命中、消耗、冷卻與絕對效果：UNKNOWN。
- Original `alchemist` class daemon 缺失造成部分職業顯示問題：PARTIAL；未推測補造。
- Original M5／M18 Evidence Gap：維持既有 PARTIAL／UNKNOWN。
- 真正 Browser 的 login → play → quit → relogin 與 KING Journey：因 Work environment offline，維持 `ENVIRONMENT-LIMITATION`。

## 9. GitHub 邊界

PR #13 必須保持 Open／Not Merged。本工作不建立 M31、不新增大型 Expansion、不修改 Original ES2 歷史層。

## 10. Deployment Readiness（部署就緒）

- Hosting-independent Container（不綁平台的容器）定義、單一 start script、`$PORT`、同源 WSS、`/health` 與 Deployment Smoke Test 已加入；細節見 `M30_DEPLOYMENT_READINESS.md`。
- `mudlib/data` 已規劃由 `ES2_SAVE_DIR` 掛載 Persistent Volume；帳號、角色、KING 與 Expansion state 都位於此持久層。
- Work 沒有 Docker／Podman／Buildah，Container Build 狀態為 `CONTAINER-ENVIRONMENT-LIMITATION`；本輪改以既有真實 Neolith Runtime 執行同一 start script 的等效 Linux 驗證。
- 沒有 persistent disk 的 Hosting 維持 `PERSISTENCE-HOSTING-LIMITATION`。
- `render.yaml` 只提供無 secret、無 disk 的相容設定，本輪沒有部署或購買服務。
- `M30 BROWSER PLAYABLE PASS` 仍未成立；必須取得真實公開 HTTPS URL 並完成 Browser Journey 後才能更新。

