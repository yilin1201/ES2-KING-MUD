# 刑天 / Headless — ES2-KING Race Design

> Original ID：`headless`
>
> 本檔案保存 ES2-KING 的刑天種族設計。
> Original ES2 考證資料請見 `original_es2/races/headless.md`。

---

## 1. 基本定位

[ES2-KING Design]

| 項目 | 設定 |
|---|---|
| 中文名稱 | 刑天 |
| ID | `headless` |
| 定位 | 高力量、高體魄、高氣血、低悟性的正面戰鬥型種族 |
| 角色建立 | 可直接選擇 |
| 武器限制 | 無 |
| 職業限制 | 暫無 |
| 特殊主動能力 | 暫無 |
| 特殊恢復 | 無 |

---

## 2. 名稱規則

[ES2-KING Naming]

ES2-KING 統一使用：**刑天**。

歷史資料中的「形天」只作為歷史異名與考證搜尋關鍵字，不取代遊戲正式名稱。

---

## 3. 世界觀設計

[ES2-KING Design]

刑天族承襲上古戰神刑天的血脈，天生具有強大的肉體力量、旺盛氣血與堅定戰鬥意志。

此族偏向以力量、體魄與持續戰鬥能力正面突破敵人，而非依靠複雜技巧取勝。強大的肉體同時伴隨較低的悟性，使其理解複雜知識與武學理論的速度較慢。

核心概念：

**力量強大、生命旺盛、意志堅定，但學習速度較慢。**

神話原型可參考《山海經》刑天／形天持干戚而舞的形象；神話資料本身不等同於 Original ES2 機制。

---

## 4. 六大基本屬性

[ES2-KING Design]

| Attribute | 中文 | 傾向 |
|---|---|---|
| Str | 力量 | 高 |
| Con | 體魄 | 高 |
| Dex | 身法 | 一般 |
| Int | 悟性 | 低 |
| Wis | 慧根 | 一般 |
| Cor | 定力 | 高 |

實際 Bonus / Penalty 數值留待全種族平衡階段統一決定。

---

## 5. Health / Resource

[ES2-KING Design]

| Resource | 中文 | 設定 |
|---|---|---|
| Kee | 氣血 | 高 |
| Gin | 精力 | 一般 |
| Sen | 神識 | 一般 |
| Force | 內力 | 依角色修練 |

刑天的生存優勢來自較高的體魄與氣血，不額外給予回血或特殊恢復能力。

---

## 6. 核心優勢

[ES2-KING Design]

### 強健體魄

方向：`Str ↑ / Con ↑ / Kee ↑`

適合正面物理戰鬥與長時間承受傷害。

### 堅定意志

方向：`Cor ↑`

代表刑天強烈的戰鬥意志；實際戰鬥公式待後續平衡階段決定。

---

## 7. 核心弱點

[ES2-KING Design]

### 悟性低下

方向：`Int ↓`

第一版學習速度設定：

```text
Headless Learning Rate = Normal Learning Rate × 0.60
```

也就是一般角色學習速度為 100% 時，刑天為 60%。

此數值是 ES2-KING 第一版平衡參數，不是 Original ES2 數值；待其他主要種族完成後再統一平衡。

---

## 8. 武器與職業

[ES2-KING Design]

第一版設計：

- 所有武器皆可使用。
- 暫不限制 Class。
- 暫不限制 Guild / Clan。

若未來門派或職業需要種族限制，另於全種族平衡階段處理。

---

## 9. 特殊能力與 Command

[ES2-KING Design]

目前不新增刑天專屬主動技能或特殊 Command。

先以 Attribute、Kee 與 Learning Rate 建立種族差異，避免第一版機制過度複雜。

---

## 10. 待平衡項目

- Str 實際加成
- Con 實際加成
- Cor 實際加成
- Int 實際減益
- Kee 實際修正公式
- 60% Learning Rate 是否維持
- 是否需要體型／負重／物理傷害修正
- 與夜叉、修羅、人類的戰鬥定位差異

---

## 11. Design Rule

本檔案所有新設定均屬 ES2-KING。

若未來找到 Original ES2 `headless` 原始碼，應先更新 `original_es2/races/headless.md`，再比較是否需要調整本設計；不得直接用 ES2-KING 設定覆蓋 Original ES2 歷史資料。
