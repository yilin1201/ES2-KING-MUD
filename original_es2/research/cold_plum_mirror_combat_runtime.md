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
- 進入戰鬥後自動啟動【明鏡止水】Combat State。

冷梅劍法：
1. 梅二方劍
2. 梅四方劍
3. 梅八方劍
4. 愛霜恨雪
5. 寒霜三千里
6. 傲梅暗劍訣

因 Original 權重未知，Expansion 第一版不宣稱任何機率；明鏡止水狀態下採 deterministic round-robin，只為確保六式都能進入真實 Combat。六式 action 的 attack/force/defense 額外係數全部為 0，讓 Original Combat Engine 決定基礎結果。

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

Real Driver E2E client:
`scripts/test_cold_plum_mirror_runtime_e2e.mjs`

Runtime PASS 需看到：
- `COLD_PLUM_PASS:arena-npc`
- `COLD_PLUM_PASS:mirror-state`
- 六個 `COLD_PLUM_PASS:form:...`
- `COLD_PLUM_PASS:weapon-combat`
- `COLD_PLUM_MIRROR_RUNTIME_PASS`

未實際跑過 Neolith Driver 前，不得宣告 Runtime PASS。
