# M17 世界區域／房間 Runtime 重建計畫

> Runtime（實機執行）：真正由 Original ES2 Mudlib（遊戲程式庫）載入並可運作的區域、房間與移動路徑。

## 目標

M16 已把 NPC（Non-Player Character，非玩家角色）、裝備與物品建立成證據分級流程。M17 接續建立 World Runtime（世界實機）證據層，優先確認區域、房間、出口與 NPC／物品出現位置，不補造公開上游沒有的地圖。

## 第一批對象

- 冷梅莊／Lengmei：與梅影風及 `fighter.lunmay` 歷史考證相關；目前是否存在可確認 Runtime room（實機房間）需重新由乾淨上游搜尋。
- 雪亭鎮：舊 ES2-KING 模擬曾作為凡間場景使用，但在 Original 層必須重新取得證據，不沿用模擬地圖。
- 其他上游可直接辨識的 `/d/` 區域：只記錄實際存在的目錄與房間程式，不把名稱相似視為同一區域。

## Evidence Gate（證據閘門）

1. Bootstrap（建立乾淨上游執行樹）後，只讀 Original ES2 Runtime tree（實機程式樹）。
2. 搜尋 `/d/` 區域、room（房間）、出口 `set("exits")`／同類結構與 NPC clone（載入非玩家角色）線索。
3. 找到候選 LPC（Lars Pensjö C，傳統 MUD 程式語言）後，先記錄 path（路徑）、inherit（繼承基底）、short／long（房間短名／描述）與 exits（出口）。
4. 找不到時標記 `UNKNOWN`（未知），不得用 ES2-KING Expansion（擴充設定）或舊模擬內容補齊。

## 第一階段交付

- `scripts/test_m17_world_runtime_gate.sh`：可重現搜尋乾淨上游世界區域證據。
- `original_es2/research/m17_world_evidence_registry.md`：保存已確認／未知的世界證據。
- GitHub Actions（GitHub 自動測試流程）：每次相關 Push 自動執行 Runtime Gate（實機證據閘門）。

## M16 → M17 銜接

M16 已確認不能把猜測 NPC path 與舊模擬數值當 Original。M17 同樣禁止把 `/d/lengmei/`、雪亭鎮或任何模擬房間路徑在沒有上游 LPC 證據時標成已確認。
