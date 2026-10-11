# 刑天 / Headless — ES2-KING Race Design

> Original ID：`headless`
>
> 本檔案保存 ES2-KING 的刑天種族設計。
> Original ES2 考證資料請見 `original_es2/races/headless.md`。

---

## Runtime 採用決策（2026-10-11）

[ES2-KING Owner Decision / Adopted ES2M Runtime]

依專案擁有者最新明確指示，**目前 KING Runtime 的刑天 `headless` 採用 `wolfer168/es2-webmud` 的 ES2M 實作與數值**，來源快照為 `es2m_snapshot/mudlib/daemon/race/headless.c`。由 `scripts/apply_race_phase2_runtime.sh` 複製到隔離 Runtime；這是 KING 的第三方版本採用決策，不代表 Original ES2 已確認。

目前 Runtime 採用的主要設定：
- 八項屬性：`str=25+random(6)`、`cor=15+random(6)`、`int=8+random(6)`、`spi=5+random(6)`、`cps=11+random(6)`、`dex=19+random(6)`、`con=23+random(6)`、`wis=13+random(6)`。
- 精／氣／神：`gin/kee/sen=80/100/30`。
- 自然護甲／攻擊／防禦：`+50/+30/+20`。
- karma 25、`commoner_score_base=160`，職業等級上限依 ES2M 檔案。
- `valid_wear()` 拒絕 `armor`、`cloth`、`head_eq`、`neck_eq`，並沿用父類別其他裝備檢查。
- 保留 ES2M 原始檔內的 limbs、體重與年齡初始化規則。

本檔其餘「ES2-KING Design」章節保存原先的設計構想與未來平衡方向，**不得誤讀為目前 Runtime 已採用的有效數值**。如需調整 Runtime，必須先由專案擁有者明確決策並同步更新來源快照、套用腳本、測試與本文件。

## 1. 基本定位

[ES2-KING Design]

| 項目 | 設定 |
|---|---|
| 中文名稱 | 刑天 |
| ID | `headless` |
| 定位 | 依 wolfer168 ES2M 設定採高臂力、高根骨、高氣血並具自然護甲與攻防加成的無首戰士 |
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

刑天沿用 wolfer168/es2-webmud 的第三方重建種族設定作為 ES2-KING Runtime 行為基準。此為使用者於 2026-10-11 明確指定的採用決策，不代表 Original ES2 已確認。

核心概念：**高臂力、高根骨、旺盛氣血、自然護甲與攻防加成；無頭、無頸部裝備。**

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
| Kee | 氣血 | 100 |
| Gin | 精力 | 80 |
| Sen | 神識 | 30 |
| Force | 內力 | 依角色修練 |

刑天的生存優勢來自較高的體魄與氣血，不額外給予回血或特殊恢復能力。

---

## 6. 核心優勢

[ES2-KING Design]

### 強健體魄

方向：`Str 25–30 / Con 23–28 / Kee 100`

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

- Class 等級上限依 ES2M `class_level_cap`：commoner 1、fighter 65、taoist 40、alchemist 40、soldier 60、scholar 50、thief 50、monk -1（`-1` 語義待 Runtime 驗證）。
- 禁止穿戴 `armor`、`cloth`、`head_eq`、`neck_eq`；其他部位交由父類別檢查。
- 武器與 Guild / Clan 限制尚未由本次來源確認，不額外推定。

若未來門派或職業需要種族限制，另於全種族平衡階段處理。

---

## 9. 特殊能力與 Command

[ES2-KING Design]

ES2M 來源包含刑天 `dance` 種族指令；Runtime overlay 會沿用該來源並由既有指令接線提供。

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

## 11. 第三方重建資料與已採用狀態

[Archived／第三方重建；來源：wolfer168/es2-webmud 的 `source/upstream/mudlib/daemon/race/headless.c`]

下列內容來自第三方重建版本，檔頭註明為使用者提供的自訂 A–H 種族資料。使用者已明確決定：刑天 Runtime 採用這份 ES2M 設定；**此採用決策不會把它變成 Original ES2 原始設定**。

| 項目 | 第三方重建值 | KING 採用狀態 |
|---|---|---|
| `str` 臂力 | 25 + random(6)，25–30 | ES2-KING Runtime 採用（第三方來源） |
| `cor` 膽識 | 15 + random(6)，15–20 | ES2-KING Runtime 採用（第三方來源） |
| `int` 悟性 | 8 + random(6)，8–13 | 僅供比對 |
| `spi` 靈性 | 5 + random(6)，5–10 | 僅供比對 |
| `cps` 定力 | 11 + random(6)，11–16 | ES2-KING Runtime 採用（第三方來源） |
| `dex` 機敏 | 19 + random(6)，19–24 | 僅供比對 |
| `con` 根骨 | 23 + random(6)，23–28 | 僅供比對 |
| `wis` 慧根 | 13 + random(6)，13–18 | 僅供比對 |
| 精／氣／神 | 80／100／30 | 僅供比對 |
| 自然護甲 | +50 | ES2-KING Runtime 採用（第三方來源） |
| 攻擊／防禦 | +30／+20 | 僅供比對；KING 未採用 |
| 裝備限制 | 不可穿 `armor`、`cloth`、`head_eq`、`neck_eq` | ES2-KING Runtime 採用（第三方來源） |

### 採用原則

1. 不將第三方數值回寫成 Original ES2 Confirmed。
2. 使用者已明確決定此版 Runtime 採用 ES2M 刑天屬性、精氣神、護甲、攻防、裝備限制與種族指令。
3. 這次採用不代表 LPC 編譯、Runtime、裝備實測或平衡測試已通過。
4. 第三方檔案中的 `random(6)` 範圍依 LPC 慣例記為 0–5，因此表格範圍為起始值至起始值加 5；最終仍以對應版本原始碼為準。

## 12. Design Rule

本檔案將 Original ES2、第三方來源與 ES2-KING 採用決策分層保存。第三方資料只有經使用者明確決策後才進入 KING Runtime；仍不得冒充 Original ES2。

若未來找到 Original ES2 `headless` 原始碼，應先更新 `original_es2/races/headless.md`，再比較是否需要調整本設計；不得直接用 ES2-KING 設定覆蓋 Original ES2 歷史資料。
