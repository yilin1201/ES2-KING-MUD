# ES2M 剩餘導入與 91 件防具整合驗證（2026-10-03）

本文件只記錄可重現的來源與離線檢查。Static PASS 不等於 Runtime 或普通玩家 Gameplay PASS。

## 剩餘來源處理

| 項目 | 結果 | 證據與處理 |
|---|---|---|
| `d/snow/bug_room.c` | 部分導入 | ES2M blob `5a2fdcf5f23bb5f75e2cd1277c06ac9b5a75e7e9` 已原樣保存；南向 `square_w`、禁止戰鬥及 `bug_board` 載入均存在。釘選 Original 已有功能相同版本，Runtime 保留 Original。 |
| `custom/wizroom/w/windstory/npc/gammer.c` | 部分導入／去重 | 與 `d/snow/npc/gammer.c` 同為 blob `11ea20374643c896080581a45c219e8d20ad8f62`。標準位置的 cane、syndicator、coin 相對依賴齊全；custom 位置無這些依賴，故不複製第二份。 |
| `daemon/skill/beast.c` | 部分導入 | 快照與 ES2M 同 SHA；釘選 Original 無此檔，且 ES2M 歷史顯示為五堂鎮／老松林擴充。缺少 `daemon/race/beast.c` 的完整 Runtime 消費鏈，不擴大導入。 |
| `obj/example/skill/fonxansword.c` | 部分導入 | 原始範例完整保存但不進 Runtime overlay；保留原檔 `damae` 拼字，不為通過測試改寫證據。 |

釘選 Original 基準為 `taedlar/es2_mudlib@cc45c06af4852380e5148dad3c9d53ff06854f2c`。該基準的 `bug_room.c`、`bug_board.c`、`std/bboard.c` blob 分別為 `e5365ba025135b3bc06e60b074ee6d54e3a1b202`、`a2f0fad4be6986c13f2451840007750d855d0258`、`ddf49aafa94a65e760797e0a6210c0b7fa595edf`。Original `bug_room.c` 與 ES2M 的功能差異只有 ES2M 的 `map/area` 註記；因此不覆蓋既有 Runtime。

## `taoism-spells.c` 差異與決策邊界

釘選 Original 沒有此檔。現存 KING 快照是 2026-09-23 ES2M 初版（blob `1ca12fb60f53c1ef17d41ca7c70a3943b8c5c38a`）；最新 ES2M 來源是 2026-10-01 Claude 提交後版本（blob `f8abe2f547842f5ad008d995126e44b8c56ea4e4`）。

| 項目 | 現存初版 | 後版來源 |
|---|---|---|
| 裝備元素加成 | 同類加成相加後限制在 -90～200 | 同類加成相加，無上下限 |
| 傷害公式 | `power × (100 + bonus) / (100 + resist)` | `(power + bonus) × 100 / (100 + resist)` |
| 最低傷害 | 1 | 1 |
| 例：power 100、bonus 50、resist 0 | 150 | 150 |
| 例：power 500、bonus 50、resist 0 | 750 | 550 |

可選決策為：A 保留初版有界乘算；B 採後版無界加算；C 另立並明確標示 KING 擴充公式。三者均會影響平衡；目前維持 UNKNOWN，不猜測 Original 公式。

## 91 件防具離線整合結果

| 檢查 | 結果 |
|---|---|
| 部位 | hand 17、head 28、leg 9、neck 15、waist 22 |
| 名稱與主要 ID | 91 組皆存在且互不重複 |
| 基本欄位 | 91 件皆有 unit、value、long、wear_as 與對應 apply mapping |
| 裝備限制 | 9 件具 class／race 限制，且限制通過後呼叫基底 `wear` |
| 唯一物件 | 3 件：lion helmet、tiger necklace、white girth |
| 特殊效果 | 1 件：corrosive hands；碎銀依賴存在，並拒絕玩家屍體 |
| NPC／商店／地圖直接引用 | 0；沒有足夠證據補造取得途徑 |
| 存檔結構 | 未發現 no_save／autoload／prevent_save 排除標記 |

檔案結構、裝備槽、限制及依賴為 Static PASS。實際裝備／卸除、特殊效果、存檔與重新登入均需要 LPC Runtime，不能由字串檢查升格為 Runtime PASS。

## 普通玩家驗證狀態

目前工作區沒有隔離 LPC driver／mudlib 執行環境，也沒有可安全使用的普通玩家測試帳號；未使用 KING、Wizard 或 Admin 權限替代。

| 項目 | 狀態 | 原因 |
|---|---|---|
| 建立角色及登入 | BLOCKED | 缺隔離 Runtime 與普通帳號 |
| 地圖移動與出口 | BLOCKED | 僅完成出口靜態雙向證據 |
| NPC 對話及互動 | BLOCKED | 僅完成 gammer 對話、任務狀態及依賴靜態證據 |
| 商店、購買及物品取得 | BLOCKED | 91 件新防具沒有來源可證的取得引用 |
| 裝備、卸除及背包操作 | BLOCKED | 缺普通玩家 Runtime |
| 戰鬥及武功施展 | BLOCKED | 缺普通玩家 Runtime；beast 仍缺完整消費鏈 |
| 存檔、登出及重新登入 | BLOCKED | 僅確認防具未宣告靜態存檔排除標記 |
