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


## Vovo2000 補強（2026-09-25）

來源：`vovo2000_es2_character_historical_evidence.md`（Archived Source，topic 29232 graph 已 DEPTH EXHAUSTED）。

- 冷梅莊：新增交叉支持梅影風、梅嵐武、楊子陵之師門／家族關係；梅嵐武為梅影風長子與接班人，歷史文字明示其冷梅劍法承自父親；楊子陵為冷梅派第一代弟子排行第四。
- 封山派：補足柳東蘆→柳淳風／柳新雨／柳繪心人物鏈；柳東蘆為掌門與前武林盟主。
- 其他可登錄人物：郭布、白齊、正閒、魯熙年、陳維俠、大觀和尚、駱易、魚鐵山、高慎、安懶道人、劉乙忘玄等。
- 歷史指令線索：魯熙年資料明示 `enlist`；城隍爺資料明示死亡鬼魂需 `register` 才能進入輪迴流程。
- 種族人物例：劉乙忘玄=厭火族；田由=形天族；黃天霸／韓夫人=夜叉族。
- 以上提升的是人物、關係、裝備與命令「存在性」的歷史可信度；NPC LPC path、HP、技能數值、掉落率仍 UNKNOWN。
