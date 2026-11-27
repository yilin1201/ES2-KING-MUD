# ES2-KING 演武界 Runtime Completion — Source Audit

## Baseline
- Branch: `build/original-es2-races-phase2`
- Starting HEAD: `23e610461bb5c3cc7831d69a263c2a43707bd7f2`
- Original ES2 fixed source: `taedlar/es2_mudlib@cc45c06af4852380e5148dad3c9d53ff06854f2c`
- 類型：ES2-KING Expansion；不回寫 Original Canon。

## Original Call Chain

1. `feature/statistic.c`
   - `consume_stat()` 將 current 降至 0 時設定 `f_exhausted[type]`。
   - `damage_stat()` 將 effective/heal 降至 0 時設定 `f_destroyed[type]`。
2. `std/char.c::heart_beat()`
   - 先將 destroyed flags 交給 `RACE_D(...)->statistic_destroyed()`。
   - 再將 exhausted flags 交給 `RACE_D(...)->statistic_exhausted()`。
3. `std/race/humanoid.c`
   - gin/kee/sen destroyed：可能降低該 statistic maximum，之後 unconscious。
   - gin/kee/sen exhausted：unconscious，並補回部分 statistic。
   - **HP exhausted：直接 `ob->die()`；玩家 living 隨後 `CHAR_D->make_ghost(ob)`。**
4. `std/char.c::die()`
   - 清戰鬥／condition、announce dead、建立 corpse。
5. `adm/daemons/chard.c::make_corpse()`
   - 非 wizard 會建立 corpse、移轉 inventory，並處理 PK／score／bounty 等永久效果。
6. `CHAR_D->make_ghost()`
   - 將 living 轉為 ghost 並重設角色狀態。

因此演武界最小安全介入點不是 Room `alternative_die()`，而是 Humanoid Race 的 **HP exhausted → die() 之前**。

## Statistic Evidence

Gemini 模擬文字不是正式依據。本輪直接由 Original Source 確認：
- `CHAR_D->setup_char()` 建立 `HP` 並使用 TYPE_HEALTH。
- Original human/avatar race initializer 建立 `gin / kee / sen`。
- `statistic.h` 正式 API 為 `query_stat_maximum/effective/current`、`set_stat_*`、`consume_stat`、`damage_stat` 等。

Expansion 敗北重塑只恢復 Original 已證實的 HP/gin/kee/sen effective/current 到既有 maximum；**maximum 本身不修改**。

## Yanwujie Boundary

條件僅為：
`environment(ob)->query("arena_zone")`

成立時，在 HP exhausted 分支：
- 不呼叫 `die()`
- 不呼叫 `make_corpse()`
- 不呼叫 `make_ghost()`
- 清除敵對與 condition
- 恢復既有 Original health statistics
- clear statistic flags
- 保持 living
- 不修改 level／score／skill／inventory／maximum statistic／save schema

演武界外完全沿用 Original death chain。

## Topology
- 天神殿：`enter → /d/arena/yanwujie`
- 演武界：`out → /d/king/wuji_realm`

## Verification
- Static Gate: `scripts/test_yanwujie_static_gate.sh`
- Real Driver E2E: `scripts/test_yanwujie_runtime_e2e.sh`
- E2E markers:
  - `YANWUJIE_PASS:enter`
  - `YANWUJIE_PASS:defeat-reconstruct-no-ghost`
  - `YANWUJIE_PASS:out`
  - `YANWUJIE_RUNTIME_PASS`

Runtime PASS 只能在真正 Neolith binary + real save_object fixture 執行上述 E2E 後宣告。
