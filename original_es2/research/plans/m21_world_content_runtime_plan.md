# M21 Original ES2 世界內容 Runtime 計畫

## 目標

在 M17 世界初步盤點與 M20 Alpha（內部初期可玩版）的基礎上，建立目前公開 Original 上游可重現的世界內容基線。

## Runtime Gate（實機證據閘門）

1. Bootstrap（建立乾淨執行樹）後確認 `mudlib/d/` 的實際區域清單。
2. 分開計算房間候選與 NPC／物品／技能程式，避免把所有 `.c` 誤報為房間。
3. 鎖定客棧大堂、廚房、廣場、城門與寺廟核心房間及其 Original 出口字串。
4. 檢查客棧大堂↔廚房與客棧大堂→廣場中央的已確認路徑。
5. 只讀 Original 上游，不修改保存原始碼。

## Regression Test（回歸測試）

- M20 的 `human + commoner + level 1` 登入與客棧大堂出生基線不得被破壞。
- M19 的寺廟鬼魂復活證據不得被世界整理改寫。
- 新增世界資料必須標示證據等級；未知內容保持 `UNKNOWN`。

## M21 完成條件

證據登錄、Runtime Gate 與 GitHub Actions（GitHub 自動測試流程）全部 PASS。M21 完成只代表目前可取得 Original 證據已形成可重現基線，不宣稱遺失的歷史區域已被補全。
