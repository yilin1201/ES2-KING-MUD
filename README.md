# ES2-KING-MUD

《東方故事2：天朝帝國》（Eastern Stories 2 / ES2）保存、考證、重建與 ES2-KING 擴充專案。

## 專案原則

**保存原作 → 理解原作 → 重建原作 → 擴充 ES2-KING**

Original ES2 與 ES2-KING 新創內容必須分開保存，不以 AI 推測補完原作資料。

## Repository 結構

```text
ES2-KING-MUD/
├── README.md / AGENTS.md
├── Dockerfile / render.yaml
├── original_es2/              # Original 保存、證據與重建
├── es2_king_expansion/        # ES2-KING Canon 與 Runtime overlay
├── king_library/              # KING 世界觀與武學設定資料庫
├── legacy_sources/            # 歷史參考來源
├── docs/
│   ├── status/                # 唯一 Current 狀態入口
│   ├── history/               # 歷史驗收紀錄
│   ├── archive/workflows/     # 已完成里程碑 Workflow 封存
│   └── migration/             # 分類與遷移清冊
├── scripts/                   # Runtime、測試、部署腳本（保持穩定路徑）
├── webtelnet/                 # Web Client 與 WebSocket/Telnet Bridge
└── .github/workflows/         # 現行 Regression / Release Gates
```

## Original ES2

`original_es2/` 只保存可追溯的原作資料、歷史資料、玩家記憶與待驗證線索。

主要證據標記：

- `[Confirmed]`
- `[Archived]`
- `[Variant-US]`
- `[Player Memory]`
- `[Unverified]`

## ES2-KING Expansion

`es2_king_expansion/` 保存本專案新增或重新設計的內容。

主要標記：

- `[ES2-KING Expansion]`
- `[ES2-KING Design]`
- `[ES2-KING Naming]`

## 第一階段

目前先建立 Race 種族資料庫與 Original / Expansion 分離架構，再逐步擴展 Attribute、Health、Class、Guild、Skill、Martial Arts、Combat、Weapon、Armor、NPC、World、Quest 與 Lifecycle。

## 專案導覽（Owner 建議閱讀順序）

1. `docs/status/CURRENT_M30_STATUS.md` — **目前唯一即時開發狀態入口**，先看這份（檔名保留歷史相容，內容已進入 M31）。
2. `ROADMAP_M0_M30.md` — M0～M30 正式鎖定路線；`ROADMAP_M31.md` — Owner 指定的 M31 Class 職業系統。
3. `docs/ES2_KING_REPOSITORY_GUIDE_ZH_TW.md` — 目前 Repository 中文分類導覽。
4. `docs/DOCUMENT_GOVERNANCE_ZH_TW.md` — 文件去重、Current／Canon／Evidence／Historical 分流規則。
5. `AGENTS.md` — 開發與 Original 保存規則。
6. `docs/SOURCES.md` — 資料來源與證據制度。

舊 M30 Audit／Playable／Deployment 文件屬歷史驗收紀錄；目前狀態以 `CURRENT_M30_STATUS.md` 為準，避免因讀到舊文件而重複測試已完成項目。

7. `docs/REPOSITORY_MASTER_CLASSIFICATION_ZH_TW.md` — **Owner 主分類總表**；用五層模型快速定位 Current、Original Evidence、Reconstruction、Expansion、Engineering。

8. `docs/status/REPOSITORY_CLEANUP_INVENTORY.md` — 最新逐檔 Cleanup 分類清冊。
