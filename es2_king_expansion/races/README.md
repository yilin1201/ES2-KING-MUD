# ES2-KING Expansion — Race Design

本目錄保存 ES2-KING 在 Original ES2 基礎上新增、調整或重新設計的種族內容。

## 核心規則

所有本目錄內容均屬 ES2-KING 新創或設計決策，應標記為：

`[ES2-KING Expansion]`、`[ES2-KING Design]` 或 `[ES2-KING Naming]`

不得把本目錄的設計反向寫成 Original ES2 歷史事實。

Original ES2 的考證資料統一保存在：

`original_es2/races/`

---

## 第一階段優先種族

1. 刑天 `headless`
2. 夜叉 `yaksa`
3. 修羅 `ashura`
4. 人類 `human`
5. 巫首 `malik`
6. 釘靈 `dingling`
7. 雨師妾 `rainnar`

其中 `malik`、`dingling` 的 Original ES2／後期版本身分仍需獨立考證；在證據完成前，不因 ES2-KING 採用而自動視為早期 Original ES2 Race。

---

## Race Design Template

每個種族設計檔至少包含：

- Original / Historical ID
- ES2-KING 中文名稱
- 種族定位
- 世界觀設定
- 八大 Attribute 傾向
- Kee / Gin / Sen / Force
- 種族優勢
- 種族弱點
- 特殊能力
- 特殊 Command
- 武器限制
- Class / Guild 限制
- 學習與成長修正
- 平衡參數
- 尚未決定項目

數值尚未完成平衡時，應明確標示為待定，不得假裝為 Original ES2 數值。


## Third-party source inventory／第三方來源索引

第三方重建種族、家園與區域資料的來源、可信度、採用狀態及待驗證事項，統一追蹤於：

`docs/research/THIRD_PARTY_CONTENT_INVENTORY_20261011.md`

收錄於來源索引只代表「已登記可追溯」，不代表已採用到 KING Runtime，也不代表 Original ES2 已確認。


## ES2M Runtime adopted races／已採用的 ES2M 種族

依專案擁有者 2026-10-11 指示，目前 Runtime 的人類 `human`、化身 `avatar` 與刑天 `headless` 採用 `wolfer168/es2-webmud` 的 ES2M 種族 daemon 快照。具體數值、來源及適用界線見：

- `human`／`avatar`：`es2_king_expansion/races/human.md`
- `headless`：`es2_king_expansion/races/headless.md`

此決策只表示 KING Runtime 採用第三方重建版本，不會把這些數值改標為 Original ES2 Confirmed。實際套用入口為 `scripts/apply_race_phase2_runtime.sh`，並由來源差異測試鎖定主要數值與複製路徑。
