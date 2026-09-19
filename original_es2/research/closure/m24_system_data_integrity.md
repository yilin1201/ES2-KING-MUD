> [ORIGINAL BASELINE CLOSURE]
> 本文件保存 Original ES2 對應里程碑的結案／證據邊界，仍可作 Original 基線參考；**不代表目前 M30 Public Acceptance 狀態**。目前狀態以 `docs/status/CURRENT_M30_STATUS.md` 為準。

# M24 Original ES2 系統整合與資料完整性

## CONFIRMED_RUNTIME（實機原始碼已確認）

- Save／Load（存檔／讀檔）：`feature/save.c` 以 `save_object()`、`restore_object()` 實作；`obj/user.c` 提供角色 `query_save_file()` 與 `save()`。
- 帳號／角色分離：`obj/login.c` 與 `obj/user.c` 各自提供保存路徑；M20 已完成同帳號重新登入驗證。
- Autoload（隨角色自動恢復物品）：`feature/user/autoload.c` 提供 `save_autoload()`、`restore_autoload()`；角色保存與 setup 流程實際呼叫。
- Condition（狀態效果）：角色 setup 呼叫 `restore_condition()`。
- Death／Revive（死亡／復活）：`std/char.c` 使用 `CHAR_D->make_corpse()`；寺廟使用 `CHAR_D->make_living()`，已由 M19 鎖定。
- Score／Experience（能力分數／經驗概念）：`feature/char/score.c` 提供 `gain_score()`；戰鬥、偷竊、購買等 Original 程式按各自規則呼叫。
- Economy（經濟）：`feature/char/finance.c` 提供 `pay_money()`、`can_afford()`；`cmds/std/buy.c` 實際扣款。
- Item protection（物品保護）：drop／give／put 等指令檢查 `no_drop`、`no_get`，避免受保護物品被任意轉移。

## UNKNOWN（未知）

- 未取得完整任務鏈前，任務進度跨登入保存仍不得宣告完成。
- 不推測所有 NPC 的掉落表、掉落率、死亡懲罰或經驗公式。
- 現有原始碼可證明介面存在，不代表所有歷史伺服器資料內容均已保存。

## 邊界

本階段不修改 Original 保存原始碼，只建立可重現的跨系統資料一致性回歸。ES2-KING Expansion（擴充內容）不得寫入 Original 保存格式作為歷史證據。
