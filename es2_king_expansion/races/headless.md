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

## 4. 八大基本屬性

[ES2-KING Design]

| Attribute | 中文 | 傾向 |
|---|---|---|
| `str` | 臂力 | 高 |
| `cor` | 膽識 | 一般 |
| `int` | 悟性 | 低 |
| `spi` | 靈性 | 一般 |
| `cps` | 定力 | 高 |
| `dex` | 機敏 | 一般 |
| `con` | 根骨 | 高 |
| `wis` | 慧根 | 一般 |

正式確認：刑天的「意志堅定」對應 `cps`（定力）並設定為高；`cor`（膽識）維持一般，不因本次修正調高。

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

方向：`cps ↑`

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
- `cor`（膽識）實際加成
- `cps`（定力）實際加成
- Int 實際減益
- Kee 實際修正公式
- 60% Learning Rate 是否維持
- 是否需要體型／負重／物理傷害修正
- 與夜叉、修羅、人類的戰鬥定位差異

---

## 11. 第三方重建資料對照（不自動採用）

[Archived／第三方重建；來源：wolfer168/es2-webmud 的 `source/upstream/mudlib/daemon/race/headless.c`]

下列內容來自第三方重建版本，檔頭註明為使用者提供的自訂 A–H 種族資料；**不是已確認的 Original ES2 原始設定，也不代表 ES2-KING 已採用這些數值**。

| 項目 | 第三方重建值 | KING 採用狀態 |
|---|---|---|
| `str` 臂力 | 25 + random(6)，25–30 | 僅供比對 |
| `cor` 膽識 | 15 + random(6)，15–20 | 僅供比對；KING 保持一般傾向 |
| `int` 悟性 | 8 + random(6)，8–13 | 僅供比對 |
| `spi` 靈性 | 5 + random(6)，5–10 | 僅供比對 |
| `cps` 定力 | 11 + random(6)，11–16 | 僅供比對；KING 保持高定力設計，實際值待平衡 |
| `dex` 機敏 | 19 + random(6)，19–24 | 僅供比對 |
| `con` 根骨 | 23 + random(6)，23–28 | 僅供比對 |
| `wis` 慧根 | 13 + random(6)，13–18 | 僅供比對 |
| 精／氣／神 | 80／100／30 | 僅供比對 |
| 自然護甲 | +50 | 僅供比對；KING 未採用 |
| 攻擊／防禦 | +30／+20 | 僅供比對；KING 未採用 |
| 裝備限制 | 不可穿 `armor`、`cloth`、`head_eq`、`neck_eq` | KING 第一版暫不限制裝備，需另行決策 |

### 採用原則

1. 不將第三方數值回寫成 Original ES2 Confirmed。
2. 不因本表而覆蓋 KING 的 `cps` 高、`cor` 一般、學習速度 60% 等既有設計。
3. 若日後決定採用任何第三方機制，須在本檔案記錄明確的 ES2-KING Expansion 決策，並增加對應 Runtime 與平衡測試。
4. 第三方檔案中的 `random(6)` 範圍依 LPC 慣例記為 0–5，因此表格範圍為起始值至起始值加 5；最終仍以對應版本原始碼為準。

## 12. Design Rule

本檔案所有新設定均屬 ES2-KING。第三方重建資料只作差異參考，不因收錄於本檔案而自動成為 KING 採用設定。

若未來找到 Original ES2 `headless` 原始碼，應先更新 `original_es2/races/headless.md`，再比較是否需要調整本設計；不得直接用 ES2-KING 設定覆蓋 Original ES2 歷史資料。
