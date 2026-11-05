# M16 NPC／裝備／物品 Runtime 重建計畫

> Runtime（實機執行）：指真正由 Original ES2 Mudlib 載入並可在遊戲環境中運作的程式內容。

## 目標

在不補造 Original ES2 未知數值的前提下，建立 NPC（Non-Player Character，非玩家角色）、裝備與物品的實機重建入口，並把「已找到原始程式」與「只有歷史文字證據」明確分離。

## 第一批證據對象

- 梅影風／May yin fong：已確認冷梅莊莊主、`fighter.lunmay` 與武學／裝備名稱；目前公開上游 Runtime source（實機原始程式）未找到。
- 劉乙忘玄：保留既有 Original ES2 人物考證；Runtime path（實機檔案路徑）與精確數值需由上游原始程式確認。
- 梅影風已確認裝備名稱：銀霜鎧、奔雲靴、梅花白襖、流雲清玉帶、白玉戒指、寒霜劍、冰雪匕。

## Evidence Gate（證據閘門）

1. Bootstrap（建立乾淨上游執行樹）後，只搜尋實際 Original ES2 Runtime tree（實機程式樹）。
2. 若找到 NPC／物品 LPC（Lars Pensjö C，傳統 MUD 程式語言）檔案，記錄實際 path、inherit、set_name、set_skill、裝備 clone 等可驗證欄位。
3. 若未找到，只回報「公開上游未找到」，不得把 ES2-KING Expansion、舊模擬戰鬥數值或推測 path 寫回 Original。
4. HP、內力、技能等級、掉落率、裝備屬性等精確數值，沒有原始碼證據一律維持 unknown（未知）。

## 第一階段交付

- `scripts/test_m16_npc_item_runtime_gate.sh`：搜尋乾淨上游 Runtime tree，輸出可重現證據結果。
- GitHub Actions（GitHub 自動測試流程）：每次相關 Push 自動執行 Evidence Gate。
- 後續若找到可驗證 LPC，再進第二階段 NPC clone／裝備載入 Regression Test（回歸測試，確認修改沒有破壞既有功能）。

## 與 M15 的銜接

M15 已證明目前公開上游找不到冷梅莊／梅影風可確認 Runtime source，因此 M16 不以猜測補齊，而是把搜尋範圍擴展到 NPC、裝備與物品，建立可持續累積的證據閘門。
