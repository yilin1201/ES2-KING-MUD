# M21 Original ES2 世界內容證據登錄表

> World Content（世界內容）：Original ES2 上游中實際存在的區域、房間、出口、NPC 與物件載入結構。

## 證據來源與範圍

- Primary upstream（主要上游）：`taedlar/es2_mudlib`。
- 本階段只把乾淨 Runtime tree（執行程式樹）中實際存在的內容標記為 `CONFIRMED_RUNTIME`。
- 目前公開上游 `mudlib/d/` 下只確認 `snow` 區域；這代表「目前保存上游的範圍」，不代表歷史 Original ES2 只有一個區域。
- 未出現在可靠上游或歷史資料中的城鎮、地圖、房間名稱、出口與 path（程式路徑）一律標示 `UNKNOWN`（未知）。

## 已確認世界基線

| 項目 | 狀態 | Runtime 證據 |
|---|---|---|
| 保存區域 | `CONFIRMED_RUNTIME` | `mudlib/d/snow/` |
| 房間候選 | `CONFIRMED_RUNTIME` | 區域根目錄 43 個 `.c` 程式，其中包含一般房間及 `BANK`、`INN`、`TEMPLE` 等房間類型。 |
| 區域全內容 | `CONFIRMED_RUNTIME` | `mudlib/d/snow/` 共 99 個 `.c` 程式，包含房間、NPC、物品及技能；類型不可互相混算。 |
| 出生／登入基線 | `CONFIRMED_RUNTIME` | `inn_hall.c`（客棧大堂） |
| 最小往返路徑 | `CONFIRMED_RUNTIME` | 客棧大堂 `west` → 廚房；廚房 `east` → 客棧大堂。 |
| 城鎮中央路徑 | `CONFIRMED_RUNTIME` | 客棧大堂 `east` → 廣場西側 `east` → 廣場中央。 |
| 復活房間 | `CONFIRMED_RUNTIME` | `small_temple.c` 繼承 `TEMPLE`，其生命週期行為由 M19 鎖定。 |

## UNKNOWN 邊界

- 未保存在目前公開上游的其他歷史區域及其完整地圖。
- Google Sites 圖像中出現、但尚未取得相符 Runtime path 的區域。
- 動態出口、條件式傳送與任務開門機制，在未逐檔核對前不得由檔名推測。
- 不使用 ES2-KING Expansion 房間填補 Original 世界缺口。
