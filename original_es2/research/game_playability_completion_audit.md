# Game Playability Completion Audit

> Audit date：2026-09-27  
> GitHub baseline：`79dfcf1b5b40fa3901c5ba221f7651975d6c844e`  
> Branch：`build/original-es2-races-phase2`  
> 原則：Evidence First；Static PASS 不等於 Runtime PASS；Quest 不以推測補齊。

## Runtime Evidence

隔離帳號 `playprobe`、`deathprobe` 只建立於 `mktemp` Runtime，不寫入正式 KING 或 Neon。測試使用真正 Neolith Driver，並經 WebSocket bridge 操作：

```text
scripts/test_game_playability_completion_e2e.sh
  -> scripts/test_game_playability_completion_e2e.mjs
  -> Neolith Driver
  -> Original Snow world
```

成功標記：

- `PLAYABILITY_PASS:connection-login-character`
- `PLAYABILITY_PASS:world-navigation`
- `PLAYABILITY_PASS:npc-interaction`
- `PLAYABILITY_PASS:item-equipment`
- `PLAYABILITY_PASS:npc-death-respawn`
- `PLAYABILITY_PASS:player-death-recovery`
- `PLAYABILITY_PASS:save-quit-reconnect-restore`
- `GAME_PLAYABILITY_COMPLETION_RUNTIME_PASS`

## PASS / UNKNOWN Matrix

| 玩家流程 | 狀態 | 真實 Runtime 證據／邊界 |
|---|---|---|
| Connection / Login | PASS | WebSocket bridge → Driver → password → existing character |
| Character | PASS | `look`、`score`、`skills`、`inventory` 可執行；正式 KING 不參與測試 |
| World Navigation | PASS | 逐段走過 Snow 保存區一般出口及 `enter`、`out`、`climb` 隱藏路徑 |
| NPC | PASS | `look`、`ask`、vendor `list`、戰鬥死亡、corpse 與 room reset 重生 |
| Item | PASS | `get`、`look`、corpse loot、inventory；未知歷史掉落表不補造 |
| Equipment | PASS | 木劍 wield／unwield、藍布長衫 wear／remove |
| Combat | PASS | NPC defeat、玩家 defeat、corpse、ghost 與寺廟復活流程 |
| Skill | PASS | 既有 Full Driver 與 Internal Skill Gate；本階段不修改凍結武功內容 |
| Apprentice | PASS | 真 Driver 已完成拜師與 relation restore |
| Class | PASS | M31 證據範圍內完成 `commoner → apprentice → alchemist` 與 restore；遺失職業仍 UNKNOWN |
| Quest | UNKNOWN | Snow NPC 存在 `try/fon` 故事旗標，但目標 Source 缺少完整轉移、入口、完成與獎勵閉環 |
| Save / Quit / Reconnect | PASS | 死亡復活後 save → quit → 新 WebSocket → login → location restore |
| Persistence | PASS | 本機 Original save/restore 本輪通過；正式 Neon opaque snapshot 與新容器 restore 保持既有 PASS |
| Full Player Journey | PASS | Login → World → NPC → Item → Equipment → Combat → Death/Recovery → Save → Quit → Reconnect |

## World Boundary

- 目前保存的 Snow top-level room Source 均可由一般出口或 Source 明示的 custom action 到達。
- `inn_staff_room` 是管理／NPC 用房間，不是玩家世界斷路，判定 NOT APPLICABLE。
- 完整歷史 ES2 世界沒有被保存，故「所有歷史地圖均已恢復」仍不得宣稱。

## Quest Evidence Boundary

目標 Branch 內 `d/snow/npc/child.c` 與 `d/snow/npc/gammer.c` 證明阿寶／瞎眼老太婆使用 `try/fon` 暫存狀態、對話與物品交付。現存 Source 只能看到部分狀態（例如 `3`、`5`、`8`、`10`、`13`、`15`、`16`、`18`、`40`、`43`、`45`、`48`、`50`），但沒有保存所有狀態轉移的 NPC／room／item 呼叫端，也沒有可由玩家從入口走到 completion/reward 的閉環。

因此 Quest 正式狀態為 `UNKNOWN`。不得把外部版本候選、聊天記錄或合理推測填入目前 Runtime。

## Known Boundary

- `tell`／`reply` 的本地玩家 routing 已由雙玩家真 Driver PASS；遺失的跨 MUD DNS／GTELL 協定維持 UNKNOWN。
- 任意 non-autoload equipment 跨登入保存仍缺 Original Evidence；不新增保存規則。
- 本階段沒有修改冷梅、寒梅、明鏡止水、傲梅暗劍、如來神掌、KING 武學或 Score UI。
