# M30 Playable Alpha Entry（M30 可遊玩 Alpha 入口）

驗證日期：2026-09-17。GitHub Actions（GitHub 自動化測試）因免費額度／US$0 預算無法啟動，狀態僅為 `ACTIONS-INFRA-BLOCKED`，本文件沒有宣稱 Actions PASS。

## 真實 Runtime

- Original ES2 mudlib：`taedlar/es2_mudlib` commit `cc45c06af4852380e5148dad3c9d53ff06854f2c`。
- Neolith Driver（MUD 遊戲執行引擎）：`neolith-1.0.0`，來源 commit `96b33bdad773713769d7af453d5989d76e69ca0a`。
- 建立：乾淨 Original tree → CMake/Ninja 編譯 Neolith → `scripts/apply_es2_king_expansion.sh` 疊加 M26～M29 → `neolith -f neolith.conf`。
- Listener（監聽埠）：真實 TCP/Telnet `127.0.0.1:4000`，socket 連線及登入 banner 實測 PASS。
- Boot：`mudlib/log/debug.log` 明確記錄 `master object is created successfully`；SimulEfun、preload daemons 與登入流程成功，無 fatal startup error。

## 真人 Playable Journey

| 步驟 | 狀態 | 真實 Driver 證據摘要 |
|---|---|---|
| Connect / Login | PLAYABLE PASS | Telnet 4000 顯示 Eastern Stories II／天朝帝國 banner。 |
| Create Character | PLAYABLE PASS | 新建帳號、密碼、email 選擇與顯示名稱完成。 |
| Race Selection | PLAYABLE PASS | 選擇 human／男性後建立角色。 |
| Class / School | PARTIAL | 平民可出生；拜陳光蕊為師與稱號成功，但 Original 缺 `alchemist` class daemon，`score` 顯示職業 `0`。不可虛構補齊。 |
| Spawn / look / score / inventory | PLAYABLE PASS | 客棧大堂出生，三個命令均有真實輸出。 |
| movement | PLAYABLE PASS | 客棧、廚房、城內往返成功。 |
| NPC interaction | PLAYABLE PASS | `look waiter`、藥鋪 `list` 與師徒對話成功。 |
| combat | PLAYABLE PASS | `kill junkman` 進入真實心跳戰鬥，`halt` 可停止。 |
| skill / learning | PLAYABLE PASS | `skills` 可用；`acquire literate from wang` 後 `sit` 進入真實授課循環。 |
| study | PARTIAL | 指令可達；本次正常玩家路徑沒有取得可研讀書籍，沒有宣稱研讀成功。 |
| enable | PARTIAL | 指令可達；新角色沒有可映射武功。 |
| exert | PARTIAL | 指令可達並正確拒絕未 enable 的內功；沒有完成一次有效施展。 |
| perform | PARTIAL | 指令可達；沒有完成一次已學招式施展。 |
| equipment | PLAYABLE PASS（管理測試） | 真實 Driver 中 clone Original 銀劍並 `wield sword` 成功；尚非新手自然取得流程。 |
| save / quit / relogin | PLAYABLE PASS | 儲存、離線、重新建立 Telnet 連線、密碼登入與角色／房間恢復均通過 M20 測試。 |

## Expansion Playable Journey

Expansion 只由 overlay 加入，沒有覆寫 Original 來源檔。

| 功能 | 狀態 | 真實 Driver 結果 |
|---|---|---|
| KING 管理員 | PLAYABLE PASS | 本機 WIZLIST 測試 fixture 登入顯示 `(admin)`；fixture 不提交為產品帳號。 |
| 天神殿・無極之境 | PLAYABLE PASS | `kingrealm` 進入 `/d/king/wuji_realm`，`look` 顯示房間與唯一 down 出口。 |
| KING Creation | PLAYABLE PASS | `kingcreate list`、`kingcreate creation_mark` 成功，創世印記進入 inventory。 |
| 易筋經 | PLAYABLE PASS | `kingmartial yijinjing 300` 回報 Lv.300／黑級無極境。 |
| 霸天煉體訣 | PLAYABLE PASS | `kingmartial batian ji` 回報既定 Expansion Canon 階段。 |
| 渾天寶鑑 | PLAYABLE PASS | `kingcanon huntian 10` 回報第十層玄宇宙。 |
| 如來神掌／十方佛兵 | PLAYABLE PASS | `kingcanon rulai 11` 回報第十一式與對應佛兵；`kingcanon turn 4` 回報神輪四轉。 |

以上 PASS 證明管理員可在真實 Driver 呼叫現有 Expansion runtime；它們尚未等同一般玩家透過任務、師承、戰鬥自然取得的完整 gameplay progression（遊戲進程），該部分維持 PARTIAL。

## 本機 Gate 與 Regression

- Driver Build：PASS（CMake 4.4.3／Ninja 1.13.2，79 build steps）。
- Driver Boot：PASS；Master object 成功，Telnet 4000 實際監聽。
- M20 真實 Telnet Alpha：PASS（獨立重新連線與 persistence／持久化）。
- M21～M24 Original Runtime Gates：PASS，對乾淨 Original tree 執行。
- M25～M30 Static／Runtime／Final Audit：PASS，對整合 runtime 執行。
- M26～M29 Static／Runtime Gates：PASS。
- M30 TODO/FIXME/placeholder/STUB 掃描：PASS（既有掃描範圍未發現）。

## Browser Entry（瀏覽器入口）

Repository 已加入 `webtelnet/`：Chrome／Edge 頁面、WebSocket（網頁雙向通訊）橋接及 Telnet TCP 轉送。`npm run check` 可做語法檢查。

目前不能提供使用者可開啟的公開網址，狀態為 `ENVIRONMENT-LIMITATION`：Work 臨時環境沒有可授權發布的公網 TCP/HTTP 端點；瀏覽器也不能直接連 raw Telnet。仍缺一個零成本或既有的公網執行位置、HTTPS/WSS 網域終端，以及在該位置同時常駐 Neolith 與 bridge。未購買、未部署任何服務。

## 已知限制

1. Original 的 `alchemist` 職業 daemon 缺失造成拜師後 `score` 職業顯示 `0`；保留為歷史原始碼缺口。
2. 一般新角色的 `study`、有效 `enable`／`exert`／`perform`，以及 Expansion 的自然取得流程尚未完成真人端到端證明。
3. Equipment PASS 使用管理 fixture，不代表新手自然裝備流程已驗收。
4. WebTelnet 已具 repository 端最小實作，但未公開部署；目前不能由外部 Chrome／Edge 進入。
5. GitHub Actions 狀態為 `ACTIONS-INFRA-BLOCKED`，不是 PASS 或程式 FAIL。
6. PR #13 必須維持 Open，禁止 Merge；本工作不建立 M31。
