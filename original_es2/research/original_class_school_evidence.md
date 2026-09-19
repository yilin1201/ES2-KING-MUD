# Original ES2 七職業與門派證據基線

> 證據狀態：`ARCHIVED_SOURCE`（歷史封存來源；使用者提供之 Original ES2 職業／門派截圖）。舊標籤 `[Confirmed Source]` 僅保留歷史相容語意，不等同 Original LPC Source Code。
>
> 規則：截圖中清楚可辨識的中文名稱與英文識別碼才列入；低解析度文字不自行猜測。

## 七大職業

| Original ID | 中文職業 | 截圖中可辨識的門派／體系 |
|---|---|---|
| `fighter` | 武者 | 封山派、雪吟莊、冷梅莊、古劍門、虎刀門、迎拳門、青邪禁衛 |
| `soldier` | 軍人 | 振武軍營 |
| `scholar` | 書生 | 玄天教、步玄派 |
| `taoist` | 道士 | 朱衣派、玄衣派、素衣派、紫衣派、幻霧觀、隱風觀、靈雲觀、道士進階 |
| `thief` | 盜賊／小偷 | 柳夷派、隱教、黑龍使者 |
| `alchemist` | 方士 | 武陀谷堂、龍圖丹派、劍甲門 |
| `bonze` | 僧侶／和尚 | 大月庵、白象寺、寶蓮寺 |

## 截圖中可辨識的程式識別

- 武者：`fighter.fonxan`、`fighter.snow`、`fighter.lunmay`、`fighter.au-chan`、`fighter.tiger`、`fighter.huge`、`fighter.7b`。
- 軍人：`soldier.ber`。
- 書生：`scholar.sky`、`scholar.myst`。
- 道士：`taoist.fire`、`taoist.storm`、`taoist.freeze`、`taoist.thunder`、`mao-shan.fog`、`mao-shan.wind`、`mao-shan.cloud`、`taoist.adv`。
- 盜賊：`thief.longye`、`thief.yin`、`thief.adv`。
- 方士：`alchemist.wu`、`alchemist.dragon`、`alchemist.adv`。
- 僧侶：`bonze.moon`、`bonze.wele`、`bonze.kind`。

## M11～M15 重建用途

1. M11 七職業以此表作為歷史職業集合的新增證據。
2. 門派是職業下一層結構，不把「職業」與「門派」合併成同一欄位。
3. `fighter.lunmay` 與冷梅莊可和既有 Original 梅影風／劉乙忘玄證據交叉考證，供 M14 師徒與 M15 冷梅莊 Runtime 重建。
4. 英文識別碼只用於追蹤 Original 結構；其精確檔案路徑、技能公式、拜師條件仍需從 Original Source 驗證，不由截圖名稱自行推導。


## 第五階段 5G — 外部 Class/School Source Recovery

外部 ES2 家族保存庫（MudRen/ES2-utf8、mudchina/es2）保留大量 `daemon/class/*` Source。這些檔案目前列為 `CORROBORATED_RUNTIME_CANDIDATE`，不得因同源 fork 數量而視為多份獨立證據。

已抽查可閉合的師門／入門 Runtime 候選：

- Scholar：駱雲舟，步玄派掌門；`attempt_apprentice` 以 `marks/桃林` 作為前置，未完成者先設 `marks/書生`，完成後 recruit 並把 class 設為 scholar。
- Taoist：林忌／六指真人，茅山派；收徒含男性限制與每日名額候選，recruit 後 class=taoist。
- Bonze：玄智和尚／山煙寺；「剃度/出家 → kneel → 改法名 → class=bonze」形成明確事件鏈，正式拜師另檢查 class/gender。
- Fighter：蕭辟塵／天邪派；`attempt_apprentice → pending/celestial_swear → swear 守門規 → recruit`，是 Story/School Quest 型入門鏈候選。
- Swordsman：柳淳風／封山劍派；拜師檢查 `cor>=20`、`cps>=20`，通過後 recruit 並 class=swordsman。

### 證據意義

這些 Source 顯示 Original ES2 家族的「職業／門派」並非只有靜態 Class Daemon，而是可透過 NPC、marks/temp state、動作／問答形成入門事件鏈。它直接支持 M11/M14/M18 的系統互相連接方式。

### 限制

- taedlar official v1.4 tree 並未保存上述全部 content，因此精確 NPC、門派、技能數值仍屬外部 lineage candidate。
- MudRen 與 mudchina 很可能共享祖先，不做雙重計票。
- 本輪不把外部 NPC 數值搬入目前 Runtime，只登錄可考證的結構與事件鏈。
