# Original ES2 Internal Skill Runtime Completion

> Baseline：`9f27811ac74e4b727acfcc5b9bd4ae565b6eb8b4`  
> Scope：只完成 Original Source 可直接證明的 `force`／`dragon force`；不推造遺失內功。

## Evidence chain

1. Player state：`feature/char/skill.c` 保存 `skills`、`learned`、`skill_map`；一般 dbase 同時保存 `force_ratio`。
2. Skill daemon：`d/snow/skill/dragon_force.c` 登記 `dragon force`，且只允許 `force` usage。
3. Command mapping：`cmds/usr/enable.c` 驗證技能與 `valid_enable()`，再建立 `force → dragon force`。
4. Exert dispatch：`cmds/std/exert.c` 讀取 `skill_mapped("force")`，設定 `force_ratio`，並呼叫對應 daemon 的 `exert_function()`。
5. Runtime effect：`dragon_force.c` 的 Original 迴圈每輪消耗精／氣／神各 10，並使用保存的 Original 隨機成長公式。
6. Combat integration：`cmds/wiz/analyze.c` 與 combat ability path 會在專用 force mapping 生效時納入 force 與 kee 修正。
7. Persistence：玩家 `save_object()` 保存技能 mapping 與 dbase；重新登入後 `restore_object()` 還原。

## Minimal runtime compatibility fix

保存來源在資源耗盡分支呼叫不存在的 `interrupt_me()`，但角色 action API 實際定義為 `interrupt()`。真 Driver 會因此留下無法結束的 busy callback，阻止後續 save／quit。

ES2-KING 只在生成 Runtime overlay 將該呼叫接回既有 `interrupt()`；Original 保存來源不被回寫，且成本、公式、技能等級、招式及門派設定均未變更。

## Runtime proof

`scripts/test_original_internal_skill_runtime_e2e.sh` 使用 `mktemp` Runtime 與隔離 KING fixture，實際驗證：

- `force` 與 `dragon force` 技能存在；
- 玩家 `enable force with dragon force` 建立正確 mapping；
- `exert 60` 寫入並讀回出力比例；
- `analyze` 顯示龍圖心經的戰鬥修正，且真正 `kill` 進入攻防回合；
- `exert dragon force` 將 35/35/35 實際消耗至低於 10，並自行結束 busy；
- `save → quit → relogin` 後技能、mapping 與出力比例完整還原。

## Remaining UNKNOWN

- 未保存的其他 Original 內功 daemon、招式與門派歸屬；
- 明鏡止水的成本、持續時間、權重與完整 Original LPC；
- 任何不在保存 Source 中的境界、傷害倍率或資源公式。

以上一律維持 UNKNOWN，不由 Expansion 倒灌。
