# Original ES2 Source Bootstrap Manifest

## 目的

本文件是 ES2-KING 導入 Original ES2 Mudlib 前的來源鎖定清單。第一階段不複製整套來源、不修改原作，而是先固定可信上游與核心程式對照，避免日後混入其他 ES2 衍生版本。

## Primary upstream

- Repository: `taedlar/es2_mudlib`
- Branch used for research: `main`
- Role: Annihilator / ES2 現行公開原始 Mudlib 最高優先來源
- Local policy: `[Confirmed]` 只能在實際對照原始碼／官方文件後使用

## 已直接驗證的核心檔案

### Character setup

Upstream: `mudlib/adm/daemons/chard.c`

[Confirmed]

- 未設定 Race → `human`
- 未設定 Class → `commoner`
- 未設定 Level → `1`
- 初始化 Statistic 與 Attribute
- `HP maximum = con * 5`
- Fatigue maximum/effective = 100
- Living / Ghost / Undead 使用不同 Statistic regeneration 規則
- 最後交由 Race daemon 與 Class daemon setup

### Score / Level

Upstream: `mudlib/feature/char/score.c`

[Confirmed]

- Race、Class、Level 分開保存
- Level 最低 1；程式檢查上限 999
- `gain_score(course, xp)` 支援多個 Score Course
- 所有 target score 都滿足後才升級
- 升級順序：Race `advance_level()` → Class `advance_level()` → level + 1
- 升級後清除 `praise_done`

### Human race

Upstream: `mudlib/daemon/race/human.c`

[Confirmed]

- Karma cost = 5
- `commoner_score_base = 100`
- Natural armor +3
- 八 Attribute 均為 `13 + random(6)`，即初始化 13–18
- Gin = 30, Kee = 30, Sen = 30
- 起始年齡 14–17
- 體重以 STR 為參數：`40000 + (str - 13) * 5000`

## ES2-KING 中文屬性名稱對照

| Code | 中文 |
|---|---|
| str | 膂力 |
| cor | 膽識 |
| int | 悟性 |
| spi | 靈性 |
| cps | 定力 |
| dex | 機敏 |
| con | 根骨 |
| wis | 慧根 |

[Confirmed] 上游 `cmds/std/identify.c` 的實際對照為：`str=膂力`、`cor=膽識`、`int=悟性`、`spi=靈性`、`cps=定力`、`dex=機敏`、`con=根骨`、`wis=慧根`。ES2-KING 依 Original ES2M 上游名稱，將 `str` 顯示為「膂力」；其餘名稱沿用上述對照。程式代碼的上游含義與 ES2-KING 顯示文字需分開記錄。

## Bootstrap 原則

下一階段採「核心最小導入」而非直接複製整個 Mudlib：

1. Character setup
2. Attribute / Statistic feature
3. Score / Level
4. Race daemon + Human
5. Class daemon + Commoner
6. User / Login 所需最小依賴
7. Room / Look / Score 指令所需最小依賴

每一批導入前先列來源路徑與授權，導入後做啟動／編譯驗證。未通過實際 Driver 測試前，不宣稱 MUD 已可玩。

## Driver 路線

上游 `taedlar/es2_mudlib` 目前搭配 Neolith；另有歷史 FluffOS / MudOS 路線。ES2-KING 第一個目標是「保留 Original 架構並能在現代環境啟動」，Driver 選擇需以實際相容性測試決定，不在研究階段自行改寫核心架構。
