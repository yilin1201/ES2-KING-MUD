# Original ES2 `score` 人物介面定義

## 狀態

`[Archived Gameplay Record]` + `[Confirmed Source]` + `[Project Canon]`

本文件鎖定 ES2-KING 重建 Original ES2 時的 `score` 人物狀態介面基準。

證據來源：

1. 使用者提供的 Original ES2 實機 `score` 畫面截圖。
2. Annihilator 現行 `taedlar/es2_mudlib`：`mudlib/cmds/usr/score.c`。

原則：**先忠實重建 Original ES2 的文字式人物狀態介面，再做 ES2-KING 擴充；不得用現代圖形 UI 取代 Original 介面。**

## 介面固定順序

```text
【 稱號／職業 】人物名稱 (player_id)

出生／年齡／性別／種族／職業敘述
目前等級、累積業力

臂力  STR    膽識  COR    悟性  INT    靈性  SPI
定力  CPS    機敏  DEX    根骨  CON    慧根  WIS

形體  current / maximum    狀態條

精    current / maximum    狀態條
氣    current / maximum    狀態條
神    current / maximum    狀態條

食物  current / maximum
飲水  current / maximum
疲勞  current / maximum

人物經驗／評價：
依角色實際 score courses 動態列出
```

> 上方 `STR/COR/...` 僅為本文件工程對照，不要求在玩家實際 `score` 畫面顯示英文代碼。

## 八大屬性正式名稱

`[Project Canon]`

| Code | ES2-KING 正式顯示名稱 |
|---|---|
| `str` | **臂力** |
| `cor` | 膽識 |
| `int` | 悟性 |
| `spi` | 靈性 |
| `cps` | 定力 |
| `dex` | 機敏 |
| `con` | 根骨 |
| `wis` | 慧根 |

### `str` 名稱差異

Annihilator 現行公開 `score.c` 的顯示文字為「膂力」。使用者已確認 ES2-KING 專案正式用語採 **「臂力」**。

因此：

- 底層屬性 Code 保持 `str`。
- Original 歷史來源若寫「膂力」，引用時保留來源原文並標示差異。
- ES2-KING 實際玩家 `score` 介面正式顯示「臂力」。
- 不因文字名稱調整而修改 STR 的數值機制。

## 生命與資源條

`[Confirmed Source]`

### 形體 `HP`

`HP` 是獨立的形體／身體生命資源。

**不得把 `kee`（氣）當成 HP。**

### 精、氣、神

- `gin` = 精
- `kee` = 氣
- `sen` = 神

三者各自具有 current / effective / maximum 狀態，並由 `tribar_graph()` 顯示狀態條。

### 狀態條

Original `score.c` 的狀態條不是單純裝飾。它使用：

- current：目前值
- effective：有效／可恢復區間
- maximum：最大值

共同計算 filled / regenerating / empty 的文字圖形狀態。

ES2-KING Original 重建時應保留這個三值概念，不簡化成單純 `current/max` 百分比條。

## 生存狀態

介面保留：

- 食物 `food`
- 飲水 `water`
- 疲勞 `fatigue`

疲勞的狀態顏色判斷方向與一般資源不同：疲勞越高代表狀態越差。

## 人物經驗／評價

`[Confirmed Source]`

Original ES2 不是固定單一 EXP 經驗條。

`score` 介面讀取角色 `score` mapping，依角色實際擁有的 score courses 動態列出人物經驗／評價；若尚未達到下一階段需求，Original 程式亦可顯示距離 target score 的差額。

因此 ES2-KING 不得把 Original 升級系統簡化成單一 `EXP`。

## 顏色與文字風格

保留 ANSI 彩色文字風格：

- 高狀態：綠色系
- 中段：黃色系
- 低狀態：紅色系
- 精／氣／神維持 Original 各自的色彩識別

實際色碼以 Mudlib ANSI 定義為準，不以截圖螢幕色偏重新定義。

## 第一版驗收畫面

MUD 可執行階段的 `score` M1 驗收至少需要：

1. 玩家可輸入 `score`。
2. 顯示角色稱號／名稱與基本人物敘述。
3. 顯示八大屬性，STR 玩家文字為「臂力」。
4. `HP`、`gin`、`kee`、`sen` 分開顯示。
5. 顯示 Original 文字狀態條。
6. 顯示食物、飲水、疲勞。
7. 顯示角色實際 score courses。
8. Human / Commoner / Level 1 測試角色的資料來源必須來自 Original 初始化機制，不手填假數據。

## Expansion 邊界

King 管理者角色、刑天與其他 ES2-KING Expansion 日後可以增加額外資訊，但：

- 不直接污染 Original `score` 基線。
- Expansion 欄位必須能清楚辨識。
- Original 測試角色必須永遠可以單獨驗證。

---

**正式定義：Original ES2 `score` 的文字結構、八大屬性、HP/精/氣/神、生存狀態與多 Score Course 顯示，列為 ES2-KING 可執行 MUD 的核心重建介面。**
