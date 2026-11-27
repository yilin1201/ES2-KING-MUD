# M22 Original ES2 角色／NPC／裝備／物品 Runtime 計畫

## 目標

在 M16 初步證據閘門與 M21 世界基線上，建立目前保存上游中 NPC、物品分類、房間載入關係及來源路徑的完整可重現清冊。

## Runtime Gate（實機證據閘門）

1. 鎖定 NPC、NPC 專屬物品與區域一般物品的實際檔案數。
2. 驗證 `F_VILLAGER`、`F_SOLDIER`、`F_VENDOR`、`F_FIGHTER`、`F_BANDIT` 等原始繼承關係。
3. 驗證市集、藥鋪、鐵匠鋪、北門、學堂、貨棧及壁爐房的代表性載入關係。
4. 被房間引用的相對 NPC／物品 path（程式路徑）必須確實存在。
5. 全程只讀 Original 上游，不修改保存原始碼。

## Regression Test（回歸測試）

- 保護 M21 的 Snow 區域與核心房間基線。
- 保護 M16 的 `CONFIRMED_TEXT`／`CONFIRMED_RUNTIME`／`UNKNOWN` 分級。
- 禁止將檔名、舊模擬數值或 Expansion 設計直接升級為 Original 史實。

## 完成條件

Static Regression（靜態回歸）與 Runtime Gate 在 Work 雲端環境本機 PASS；GitHub Actions 若因免費額度無法啟動，記錄 `ACTIONS-INFRA-BLOCKED`，不得假稱 Actions PASS。
