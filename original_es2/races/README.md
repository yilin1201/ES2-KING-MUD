# Original ES2 Race Database

本目錄保存《東方故事2：天朝帝國》（ES2）Original Race 種族系統的考證資料。

## 核心原則

本資料庫以 Annihilator / Original ES2 Source Code 與官方文件為最高優先來源。

不得因資料缺失而自行創造 Original ES2 的種族設定。

證據標記：

- `[Confirmed]` 原始碼或原始文件確認
- `[Archived]` ES2 歷史資料確認
- `[Variant-US]` 北美或其他衍生版本
- `[Player Memory]` 專案擁有者原版遊玩記憶
- `[Unverified]` 尚待確認

ES2-KING 新創內容不得寫入本目錄；統一放在 `es2_king_expansion/races/`。

---

## 已確認存在於目前 Original ES2 文件索引的 Race ID

| Original ID | 專案中文對應 | ID 狀態 | 中文名稱／能力狀態 |
|---|---|---|---|
| human | 人類 | [Confirmed] | 持續考證 |
| woochan | 無腸 | [Confirmed] | [Player Memory / Unverified] |
| jiaojao | 焦僥 | [Confirmed] | [Player Memory / Unverified] |
| yenhold | 厭火 | [Confirmed] | [Player Memory / Archived / Unverified] |
| rainnar | 雨師妾 | [Confirmed] | [Player Memory / Unverified] |
| ashura | 修羅 | [Confirmed] | 持續考證 |
| headless | 刑天 | [Confirmed] | 歷史異名「形天」；持續考證 |
| yaksa | 夜叉 | [Confirmed] | 持續考證 |
| blackteeth | 黑齒 | [Confirmed] | [Player Memory / Unverified] |

注意：Race ID 的存在與「完整種族機制已確認」是兩件不同的事。屬性、能力、公式、限制仍需逐項取得證據。

---

## 後期歷史資料出現、版本身分待考證

| ID | 專案中文對應 | 狀態 |
|---|---|---|
| malik | 巫首 | [Archived / Unverified] |
| dingling | 釘靈 | [Archived / Unverified] |

`malik`、`dingling` 對 ES2-KING 很重要，但在確認其加入年代與 Original ES2 版本關係前，不列入上方「目前 Original 文件索引已確認 Race ID」。

---

## 已知玩家記憶線索

### 焦僥 / jiaojao

[Player Memory]

適合盜賊／小偷相關發展。需確認 Thief Class、Dex、Cor、Backstab 與實際 Race Bonus。

### 厭火 / yenhold

[Player Memory]

具有噴火相關種族能力，玩家記憶傾向消耗精力。能力名稱、Command、實際消耗、傷害與限制仍需原始碼驗證。

### 雨師妾 / rainnar

[Player Memory]

具有養蛇相關能力，玩家記憶中可使用自身血進行養蛇／煉蛇。Snake Object、Command、成長、戰鬥與死亡機制仍需驗證。

---

## 每個 Race 的考證 Checklist

- Original / Historical ID
- 中文名稱與版本
- Race Object / Source File
- 種族背景
- 出生設定
- 八大 Attribute
- Attribute Bonus / Penalty
- Kee / Gin / Sen / Force
- 特殊能力
- 特殊 Command
- 特殊物件
- 職業適性與限制
- Guild / Clan 限制
- Skill / Combat Bonus
- Lifecycle / Death
- 業力需求
- 創角條件
- 版本差異

---

## 第一階段研究優先順序

ES2-KING 專案目前優先建立七個主要種族：

1. `headless` / 刑天
2. `yaksa` / 夜叉
3. `ashura` / 修羅
4. `human` / 人類
5. `malik` / 巫首
6. `dingling` / 釘靈
7. `rainnar` / 雨師妾

此順序代表「專案研究與建構優先度」，不代表七者都屬於同一 Original ES2 歷史版本。

其他已知種族 `woochan`、`jiaojao`、`yenhold`、`blackteeth` 保留並於第二階段持續考證。

---

## Original ES2 Preservation Rule

本目錄只負責：

**保存 → 考證 → 重建 → 驗證**

任何新增能力、平衡數值或世界觀擴寫必須放入：

`es2_king_expansion/`

不得以 ES2-KING 設計反向補完 Original ES2。
