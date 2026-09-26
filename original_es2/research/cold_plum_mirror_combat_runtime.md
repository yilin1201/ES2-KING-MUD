# 冷梅劍法／明鏡止水 Combat Runtime Completion

## Evidence Boundary

- Original ES2 Combat 入口：`feature/char/attack.c::attack()`。
- 持劍時：`skill_mapped("sword") → weapon->attack_with() → SKILL_D(mapped)->attack_using()`。
- 最終命中／力道／防禦／傷害仍交由 `COMBAT_D->fight()`。
- Original `F_SKILL` 一般 skill level 上限為 200；梅寒霜的「300」是使用者指定的 Arena Expansion 測試規格，因此只在 NPC 本體做 local effective-level override，不修改全域 Skill 規則。
- 明鏡止水定位：高階寒梅心法進階戰鬥境界。續航提升的數值、恢復量、消耗、持續時間與六式權重仍缺 Evidence，維持 UNKNOWN。

## Runtime Implementation

梅寒霜：
- 八屬性 str/cor/int/spi/cps/dex/con/wis = 50。
- 指定冷梅 Skills 與基本 Combat usage 對此 Arena NPC effective = 300。
- `sword → lunmay`。
- 使用「焦黑枯梅枝」；武器傷害模板直接沿用 Original ES2 `woodsword.c` 的 `setup_sword(1,14,40,0)`，沒有另造神器倍率。
- 進入戰鬥後由寒梅心法體系自動啟動【明鏡止水】Combat State；寒梅心法、傲梅暗劍訣、冷梅劍法等既有 Evidence skill ID 均保留於梅寒霜配置。

冷梅劍法：
1. 梅二方劍
2. 梅四方劍
3. 梅八方劍
4. 愛霜恨雪
5. 寒霜三千里
6. 傲梅暗劍訣・傲雪藏鋒・逆折寒梅

其中前五式為冷梅劍法正式招式；第六式為傲梅暗劍訣進階殺招【傲雪藏鋒・逆折寒梅】。
武訣：「明劍欺敵，暗劍藏殺；傲雪藏鋒・逆折寒梅。」右手冷梅劍法為陽面明劍、左手傲梅暗劍為陰面藏殺；咽喉、心口、氣海僅屬 Combat 文字敘事，不建立必中、必殺或額外數值。

因 Original 權重未知，Expansion 第一版不宣稱任何機率；明鏡止水狀態下採 deterministic round-robin，只為確保六式都能進入真實 Combat。六式 action 的 attack/force/defense 額外係數全部為 0，讓 Original Combat Engine 決定基礎結果。

KING：
- `kingrealm` 只對通過既有 Owner/Admin 授權的 `king` 套用正式配置，沒有降低或繞過權限。
- str/cor/int/spi/cps/dex/con/wis 由正式 attribute API 設為 99；非 KING 仍受 Original 50 上限保護。
- `hainmay force`、`advance_lunmay`、`lunmay`、`mayin`、`seven` 與五個基本 Combat usage 均為 200，遵守 Original 玩家技能上限。
- `force → hainmay force`、`sword → lunmay`；明鏡止水 marker 與完整武學資料沿用既有 save/restore，不建立平行帳號資料來源。

## 明鏡止水

已實作：
- Combat State 啟動。
- 啟動訊息。
- 狀態驅動冷梅六式 Combat Action。

仍 UNKNOWN：
- 戰鬥續航的實際恢復公式。
- 劍術額外命中／攻擊／招架倍率。
- 消耗、持續時間、解除條件。
- 六式 Original 權重。

因此不得把目前版本描述成已復原 Original 明鏡止水完整數值；它是 Evidence-bounded Expansion Runtime。

## Gates

Static:
`scripts/test_cold_plum_arena_static.sh`

KING／拓撲 Static:
`scripts/test_cold_plum_martial_system_static.mjs`

Real Driver E2E client:
`scripts/test_cold_plum_arena_runtime_e2e.sh`

Runtime PASS 需看到：
- `COLD_PLUM_PASS:king-99-skills-admin`
- `COLD_PLUM_PASS:wuji-enter-yanwujie`
- `COLD_PLUM_PASS:npc-attributes-skills`
- `COLD_PLUM_PASS:arena-defeat-protection`
- `COLD_PLUM_PASS:mirror-mind-state`
- `COLD_PLUM_PASS:six-forms-runtime`
- `COLD_PLUM_PASS:king-combat-mei`
- `COLD_PLUM_PASS:yanwujie-out-wuji`
- `COLD_PLUM_PASS:save-quit-relogin-restore`
- `COLD_PLUM_RUNTIME_PASS`

2026-09-26 已以臨時 Runtime 與隔離 KING fixture 在真實 Neolith Driver 通過上述完整 E2E；未讀寫正式 KING／Neon 玩家資料。重登位置依 Original 安全登入策略回到客棧大堂，但 KING 8×99、十項技能、force/sword mapping 與明鏡止水持久資料均由新連線重新查證成功。
