# Original ES2 Race Reconstruction — Phase 2

Status: EVIDENCE GATE PASS / RUNTIME FORMULAS STILL UNDER RECOVERY
Branch: `build/original-es2-races-phase2`
Base: M0–M5 merged `main` (`9740478cad342c3193c5e0f611427e31f5fa1fbc`)

## Safety rule

Original ES2 races are reconstructed only from recoverable evidence. Missing race daemons, numerical initializers, natural armor, age, or special abilities MUST NOT be invented. ES2-KING expansion data remains separate.

## Confirmed source cross-check

Archived Original ES2 wizard documentation lists race topics for `human`, `woochan`, `jiaojao`, `yenhold`, `rainnar`, `ashura`, `headless`, `yaksa`, and `blackteeth`. Original `who.c` independently preserves historical race filters including `headless` and `malik`.

Original `mudlib/data/chinese.o` supplies direct source mappings including `headless` → `形天`, `yaksa` → `夜叉`, `ashura` → `阿修羅`, `rainnar` → `雨師妾`, `woochan` → `無腸`, `jiaojao` → `焦僥`, `yenhold` → `厭火`, `blackteeth` → `黑齒`, `malik` → `巫首`, and `human` → `人類`.

## Archived gameplay race-selection evidence

A 2014 ES2 gameplay record preserves the actual reincarnation race-selection menu:

| ID | Original display | Karma |
|---|---|---:|
| blackteeth | 黑齒 | 5 |
| human | 人類 | 5 |
| yenhold | 厭火 | 5 |
| woochan | 無腸 | 5 |
| dingling | 釘靈 | 10 |
| jiaojao | 焦僥 | 10 |
| rainnar | 雨師妾 | 25 |
| ashura | 阿修羅 | 30 |
| headless | 形天 | 25 |
| yaksa | 夜叉 | 30 |
| malik | 巫首 | 30 |

Important: both Original source translation data and archived live game text spell `headless` as **形天**. Original ES2 data therefore preserves 形天 rather than silently rewriting it as 刑天.

Machine-readable registry: `original_es2/data/historical_race_registry.json`.

## Additional archived gameplay cross-check

A surviving level-65 male 形天 character record confirms `headless` was playable in the live game. The archive also preserves `形天之怒 (Girdle of headless)` and a weapon modifier named 形天 that grants +3 strength. These confirm historical vocabulary/content, but do not prove the race's birth initializer.

## Current executable baseline

Current Annihilator main exposes registered `human` and `avatar` race daemons. M5 already verifies both end-to-end at runtime. Missing historical race implementations must therefore be recovered separately rather than fabricated.

## M6 accelerated result

PASS:
- `headless` → `形天` is now confirmed by Original source and archived gameplay.
- All 11 archived selectable race IDs, Chinese names, and karma costs are locked in a structured evidence registry.
- No guessed initializer/effect has entered Original runtime code.

Still unresolved:
- exact eight-attribute birth formulas for `headless`
- initial Gin/Kee/Sen overrides, if any
- natural armor, age/lifespan, and race-specific runtime effects

Current searched repositories contain no historical `mudlib/daemon/race/headless.c` commit history. High-level player score records cannot safely reconstruct birth formulas because attributes can change through level growth, skills, equipment, and other gameplay systems.

## Next implementation gate

Do not create a guessed `headless.c`. Continue archive/source recovery. Once Original formulas are recovered, implement live 形天 creation and verify creation, score, persistence/relogin, movement, and combat, then run the full regression gate before merge review.


## 第五階段 5N — Race P0 Recovery Boundary Recheck

依目前 Evidence Master/Conflict Register/Google Sites race table 重新核對 P0：

- 11 個歷史 selectable ID／名稱／業力有 Archived Gameplay 與部分 Original Source 支持，但黑齒 3/5、夜叉 35/30 保留版本衝突。
- Google Sites 已提供各族「初始屬性上限」與精／氣／神等設定；**上限不是出生 initializer 公式**，不得把上限直接寫成固定出生值。
- `human_clan` 仍只是 ES2-KING Reconstruction ID；Original 第二人類族 ID 未取得 Source。
- 外部 ES2 family repositories 的大量 Class/Quest content 並未補回 headless/yaksa 等 race daemon，因此 P0 initializer 缺口沒有因第五階段其他突破而消失。

### Runtime Gate 維持

在找到直接 race daemon／birth initializer／可信歷史創角公式前：
1. 不新增猜測的 historical race daemon。
2. 不以 Google Sites attribute cap 取代 initializer。
3. 不以高等玩家 Score 反推出生值。
4. Race Evidence Gate 可 PASS「證據存在／ID 已鎖」，但不得寫成「歷史 Race Runtime 已完整恢復」。
