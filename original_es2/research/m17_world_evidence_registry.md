# M17 世界區域／房間證據登錄表

> Evidence Registry（證據登錄表）：只保存 Original ES2 可追溯證據；ES2-KING 模擬與 Expansion（擴充設定）不得直接升級為 Original。

## 證據分級

- `CONFIRMED_TEXT`（文字證據已確認）：歷史文字／既有考證可支持名稱或關係。
- `CONFIRMED_RUNTIME`（實機原始碼已確認）：乾淨 Original ES2 Runtime tree 中已找到可核對 LPC 原始程式。
- `UNKNOWN`（未知）：目前沒有足夠 Original ES2 實機證據。

## 第一批區域

| 區域／場景 | 目前證據 | Runtime 狀態 | 不可補造內容 |
|---|---|---|---|
| 冷梅莊／Lengmei | 與梅影風、`fighter.lunmay` 歷史考證相關 | `UNKNOWN` | `/d/lengmei/` 精確路徑、房間清單、出口、NPC 出生點 |
| 雪亭鎮 | 舊 ES2-KING 模擬曾使用此場景名稱 | `UNKNOWN` | 城鎮地圖、中心廣場 path、出口、NPC／物品位置 |

## 原則

1. `CONFIRMED_RUNTIME` 必須能指向乾淨上游實際 LPC（Lars Pensjö C，傳統 MUD 程式語言）檔案。
2. 只有名稱相似、舊聊天模擬或 ES2-KING Expansion 設定，不足以升級 Runtime 證據。
3. 房間 short／long（短名／描述）、exits（出口）、NPC clone（載入非玩家角色）與物品放置位置都需逐項核對。
4. M17 Runtime Gate 找到候選檔案後，先人工／程式逐檔驗證，再更新此表。


## 第五階段 5I — World/School Source Cross-reference

外部 ES2 家族 Source 可將部分「世界房間」與「職業／門派事件」直接連接：

- `daemon/class/scholar/entrance.c` 曼雩台：西接 `/d/choyin/bridge5`，東接桃林，並 clone Scholar master。
- `d/choyin/taolin.c` 桃林：不是純地圖房，而是具有 read/go 解謎邏輯、玩家 `taolin_steps` 與 `marks/桃林` 狀態的事件房。
- `d/waterfog/guildhall.c` 水煙閣正廳：`CLASS_GUILD`，明示「加入武者同盟後向各大門派拜師」，並 clone Fighter champion/master/executioner。

因此 World Runtime 應區分：
1. **Navigation Room（導航房間）**：只負責出口／位置。
2. **Event Room（事件房間）**：房間本身承載 Quest/School state transition。
3. **Class Guild Room（職業公會房）**：連接 Class Engine 與 School NPC。

此分類由外部 Source 直接觀察得到，先列 `CORROBORATED_RUNTIME_CANDIDATE`；不代表所有目標 Original 地圖都已回收。


## Vovo2000 世界觀補強（2026-09-25）

Archived Source 現已直接支持：雪亭鎮是故事起點；世界主線涉及嵐城、旋芒寶劍、穿靈寶劍、寒於寶衣、侮天鬼與杞庸／金烏。並保存寒於氏十三精靈：金烏、銀蟾、大鵬、天龍、澤獸、鳳凰、赤魈、青蛛、濁魚、旱魃、穹氤、域摩、區冥，以及「六神、四鬼、三靈」分類。

因此「雪亭鎮」由僅舊模擬名稱提升為 `CONFIRMED_TEXT` 的歷史世界名稱／故事起點；但房間 path、出口、NPC clone、出生點仍 UNKNOWN，不因此建立猜測地圖。
