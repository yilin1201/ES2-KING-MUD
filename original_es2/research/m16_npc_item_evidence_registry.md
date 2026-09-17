# M16 NPC／裝備／物品證據登錄表

> Evidence Registry（證據登錄表）：集中記錄目前能確認與不能確認的 Original ES2 資訊，避免把 ES2-KING 擴充或舊模擬資料誤寫成 Original。

## 證據分級

- `CONFIRMED_TEXT`（文字證據已確認）：已有 Original ES2 歷史文字／既有考證支持，但尚未取得可執行 LPC 原始程式。
- `CONFIRMED_RUNTIME`（實機原始碼已確認）：已在乾淨 Original ES2 Runtime tree（實機程式樹）找到可核對 LPC（Lars Pensjö C，傳統 MUD 程式語言）原始碼。
- `UNKNOWN`（未知）：目前沒有足夠 Original ES2 證據，不補造數值或路徑。

## 第一批 NPC

| 對象 | 已確認 | Runtime 狀態 | 保持未知 |
|---|---|---|---|
| 梅影風／May yin fong | 冷梅莊莊主、`fighter.lunmay`、既有武學與裝備名稱 | `UNKNOWN`：目前公開上游未找到可確認 NPC LPC | NPC path、HP、內力、技能等級、完整 `set_skill`／`map_skill`、掉落率 |
| 劉乙忘玄 | 既有 Original ES2 人物考證 | `UNKNOWN`：目前公開上游未找到可確認 NPC LPC | NPC path、HP、內力、技能等級、裝備屬性、掉落率 |

## 梅影風第一批裝備名稱

以下只提升到 `CONFIRMED_TEXT`，不宣告其 Runtime path 或屬性：

- 銀霜鎧
- 奔雲靴
- 梅花白襖
- 流雲清玉帶
- 白玉戒指
- 寒霜劍
- 冰雪匕

## Runtime Gate 結論

M16 第一階段 GitHub Actions（GitHub 自動測試流程）已成功執行 Runtime Gate（實機證據閘門）。目前策略維持：

1. 公開上游找不到原始 LPC 時，不建立虛構 NPC path。
2. 不使用舊模擬戰鬥中的 HP、內力、等級作為 Original 數值。
3. ES2-KING Expansion（ES2-KING 擴充設定）可另行保存，但不得反寫到 Original 證據層。
4. 後續找到候選 LPC 時，必須先逐檔核對 `inherit`、`set_name`、`set_skill`、`map_skill`、clone／裝備載入等欄位，再升級為 `CONFIRMED_RUNTIME`。

## 下一階段

建立 Static Regression（靜態回歸檢查，不啟動遊戲即可確認資料邊界）以自動阻止：

- 把梅影風模擬 HP／內力寫進 Original 登錄表；
- 把猜測的 `/d/lengmei/npc/meiyingfeng` 等路徑標成 Original 已確認；
- 把 ES2-KING Expansion 的設定誤標為 Original Runtime 證據。
