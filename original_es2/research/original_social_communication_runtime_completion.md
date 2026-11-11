# Original ES2 Social / Communication Runtime Completion

## Original Source

固定 Original ES2 commit：`cc45c06af4852380e5148dad3c9d53ff06854f2c`

- `mudlib/cmds/std/say.c`：發送者輸出、同房 `message()`、`relay_say()`。
- `mudlib/cmds/std/tell.c`：`find_player()`、interactive 檢查、ignore、訊息長度／間隔、成功後寫入 `reply` target。
- `mudlib/cmds/std/reply.c`：讀取 `reply` target、online／interactive、ignore／netdead，再反向更新 reply target。

## Runtime Gate

新增雙玩家隔離 Gate：
- `scripts/test_original_social_communication_runtime_e2e.sh`
- `scripts/test_original_social_communication_runtime_e2e.mjs`

兩個測試玩家由 real Runtime KING fixture 複製到 `mktemp` Runtime，只改隔離副本的 ID、顯示名與隨機測試密碼；不使用正式 KING、不接觸 Neon 正式玩家資料。

預定實機驗證：
1. say 同房傳送與 UTF-8。
2. tell 私訊與 identity routing。
3. reply 依 Original temp reply target 回覆。
4. 不存在玩家的 Original error。
5. Player B quit 後 tell 不得成功。
6. Player B 新連線 relogin 後 tell 恢復。

## Evidence Boundary

本輪未修改 Original `say.c`／`tell.c`／`reply.c`，因 Source 已存在完整主路徑；不為產生 Commit 而重寫 Original。

目前聊天執行環境沒有 Work 先前建立的本機 Neolith binary 與 real save_object fixture，故尚未執行真實 Driver Gate。Static／Source Evidence 不冒充 Runtime PASS。

最終狀態：**PARTIAL / RUNTIME GATE READY**。

待 Gate 真實執行並出現全部 `SOCIAL_PASS:*` 與 `ORIGINAL_SOCIAL_COMMUNICATION_RUNTIME_PASS` marker 後，才可升級為 IMPLEMENTED。
