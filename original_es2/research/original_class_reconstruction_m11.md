# M11 Original ES2 Class／職業系統重建基線

## 目的

本文件只記錄目前能由 Original ES2 原始碼確認的 Class（職業類別）證據，不補寫已遺失職業的公式或能力。

## [Confirmed Source] 現存職業 Daemon

目前保存的 `mudlib/daemon/class/` 只有兩個實體職業程式：

- `commoner`：`query_rank()` 無敬語時回傳「平民」。
- `fighter`：`query_rank()` 無敬語時回傳「武者」。

這兩個檔案是目前可直接執行與驗證的 Original Class 基線。

## [Confirmed Source] 歷史職業 ID 線索

Original NPC 原始碼仍可確認其他 Class ID 曾被實際使用：

- `thief`：焦僥族 `traveller.c` 使用 `set_class("thief")`。
- `soldier`：黑白無常 NPC 使用 `set_class("soldier")`。

目前保存的 `daemon/class/` 並沒有 `thief.c`、`soldier.c`，因此只能確認 ID 曾存在／被引用；其正式中文職業名稱、初始化公式、升級公式、能力修正與玩家取得方式均標記 **[Unverified] 待考證**。

## [Confirmed Source] Class 核心呼叫流程

Original `feature/char/score.c` 可確認：

1. `set_class(new_class)` 會把職業 ID 寫入角色 `class`。
2. 當角色已具有 level 與 race 時，會重新執行 Race 與 Class 的 `initialize()`。
3. `set_level()` 在 race/class 都存在時同樣會重新初始化 Race 與 Class。
4. `gain_score()` 滿足升級條件後會依序呼叫 Race 與 Class 的 `advance_level()`，再增加角色 level。

因此 Class 不是單純顯示文字，而是 Original ES2 角色初始化與升級架構的一部分。

## M11 第一階段執行策略

- 先保護 `commoner` 與 `fighter` 原始程式，不修改 Original 證據。
- Runtime（實際執行環境）先驗證兩個現存 Class 能被 Neolith 載入並參與角色/NPC 建立。
- `thief`、`soldier` 暫不建立假 Daemon；找到足夠 Original 證據前只保留 ID 證據。
- 後續若取得更多歷史 Class ID，先加入證據表，再決定是否建立重建層。

## 完成條件

M11 不以「猜出七職業」為完成條件。第一階段完成條件是：現存 Class 架構可執行、Class ID 證據被保存、缺失部分不被 AI 擅自補完，並能納入 Regression Test（回歸測試）。
