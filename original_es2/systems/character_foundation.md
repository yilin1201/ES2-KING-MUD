# Original ES2 Character Foundation

> 狀態：研究基礎文件，尚非可執行 Mudlib。

本文件整理目前已取得證據的 Original ES2 玩家角色核心資料，作為後續導入／重建 Mudlib 的規格基準。不得以 ES2-KING 新創內容反向補完 Original ES2。

## 1. 角色核心架構

目前研究模型：

`User → Character → Race → Class → Level → Attribute → Statistic → Score/Progression → Skill → Combat → Life Form`

其中 Race、Class、Level 為不同資料層；Skill 的「擁有、熟練度、學習點、目前 enable/map」亦不可混為同一狀態。

## 2. 八大基本屬性 Attribute

上游來源：`cmds/std/identify.c`。

[Confirmed] 上游原始碼的代碼與中文名稱如下。ES2-KING 顯示名稱另依專案決定處理；`str` 的上游中文為「膂力」，但本專案正式顯示為「臂力」。

| Code | 上游原始碼中文 | ES2-KING 顯示名稱 | 狀態 |
|---|---|---|---|
| `str` | 膂力 | 臂力 | [Confirmed upstream / Owner display decision] |
| `cor` | 膽識 | 膽識 | [Confirmed] |
| `int` | 悟性 | 悟性 | [Confirmed] |
| `spi` | 靈性 | 靈性 | [Confirmed] |
| `cps` | 定力 | 定力 | [Confirmed] |
| `dex` | 機敏 | 機敏 | [Confirmed] |
| `con` | 根骨 | 根骨 | [Confirmed] |
| `wis` | 慧根 | 慧根 | [Confirmed] |

**衝突修正規則：** `cor = 膽識`、`cps = 定力`。不得將兩者對調。若其他文件仍出現 `cps = 膽識` 或 `cor = 定力`，應視為舊版文件錯誤並依上游 `cmds/std/identify.c` 修正。

## 3. 角色資源

- `gin` = 精
- `kee` = 氣
- `sen` = 神
- `hp` = 形體生命／HP，與 Kee 分離
- `fatigue` = 疲勞

[Confirmed] 目前原始角色初始化研究顯示，HP maximum 與 `con`（根骨）相關，基準為 `con * 5`。

禁止把 Kee 當成 HP。

## 4. 七大職業 Class

[Archived / Player Record]

- `fighter` 武者
- `taoist` 道士
- `bonze` 僧侶／和尚
- `scholar` 書生
- `thief` 盜賊／小偷
- `soldier` 軍人
- `alchemist` 方士

後續需逐職業回查 Original Class Object 與 `advance_level()`。

## 5. 升級時精氣神成長線索

[Archived / Player Record — Source Code Verification Required]

| 職業 | 精 Gin | 氣 Kee | 神 Sen |
|---|---|---|---|
| 道士 | 機敏 / 4 | 根骨 / 4 | 靈性 / 3 |
| 武者 | 機敏 / 4 | 根骨 / 2 | 靈性 / 8 |
| 盜賊 | 機敏 / 2 | 根骨 / 4 | 靈性 / 8 |
| 方士 | 機敏 / 4 | 根骨 / 4 | 靈性 / 4 |
| 書生 | 機敏 / 5 | 根骨 / 3 | 靈性 / 3 |
| 軍人 | 機敏 / 3 | 根骨 / 3 | 靈性 / 8 |
| 和尚 | 機敏 / 6 | 根骨 / 6 | 靈性 / 6 |

整數取值、隨機項、額外 Race/Class 修正仍待原始碼驗證，因此目前不得直接寫死成正式遊戲公式。

## 6. Skill 練功線索

[Archived / Player Record]

- INT／悟性會影響部分技能練功取得的經驗。
- 玩家資料記錄一個 `int / 7` 取整數的經驗基數；部分武功可能例外。
- `dodge` 縱躍閃躲、`parry` 拆招卸力、`unarmed` 徒手搏鬥、`force` 內功均有實戰／練習型成長方式。
- `force` 是技能／映射技能系統的一部分，不應建模成與 Gin/Kee/Sen 平行的第四個 Statistic bar。

## 7. Derived Combat Stats 衍生戰鬥能力

目前歷史資料與玩家裝備資料確認存在：

- 攻勢等級
- 攻擊能力
- 傷害力
- 守勢等級
- 防禦能力
- 防禦力／護甲強度
- 行動／移動力
- 警覺
- 咒文能力
- 法術能力
- 火焰／冰寒／雷電／風擊傷害與防禦
- 拆招卸力、縱躍閃躲、內功等技能加成

[Archived / Player Record] 警覺公式線索：

`警覺 = 靈性 * 定力 / 10 + gin / 16`

仍需找到 Original combat/source 實作後才能升級為 [Confirmed]。

## 8. Score / Progression

[Confirmed] Original score 系統允許多個 Score Course；Race、Class、Level 分開保存。升級需要滿足目標 Score，再呼叫 Race / Class 的 `advance_level`。

因此 ES2-KING 重建不得簡化成單一 EXP bar。

玩家升級試算資料另顯示 Level² lookup curve，以及 Race coefficient、Class 所需 Score Courses 等線索；完整目標公式仍待逆向與原始碼驗證。

## 9. Life Form / Death

[Confirmed / Archived]

角色至少需區分 living、ghost、undead 等生命形態。死亡後 Ghost 的可用資源、指令與復活流程不同；玩家歷史資料另記錄屍體腐爛、疲勞與 Gin/Kee/Sen 永久損失等規則，需逐項回查死亡／地府程式。

## 10. 下一個可執行里程碑

在真正開始寫可玩的 MUD 前，先完成：

1. 匯入／對照 Original ES2 Mudlib 骨架。
2. 找到 Character / Race / Class / Score / Skill 的原始實作。
3. 建立最小測試角色：Human + Commoner + Level 1。
4. 驗證八 Attribute、Gin/Kee/Sen、HP、Fatigue。
5. 再建立第一個 ES2-KING 測試 Race（刑天），但 Expansion 與 Original 必須分離。

完成以上驗證後，才進入登入、創角、第一房間與 `look` / `score` 指令的可玩階段。
