# ES2-KING-MUD

《東方故事2：天朝帝國》（Eastern Stories 2 / ES2）保存、考證、重建與 ES2-KING 擴充專案。

## 專案原則

**保存原作 → 理解原作 → 重建原作 → 擴充 ES2-KING**

Original ES2 與 ES2-KING 新創內容必須分開保存，不以 AI 推測補完原作資料。

## Repository 結構

```text
ES2-KING-MUD/
├── AGENTS.md                 # 專案工作規則
├── README.md                 # 專案入口
├── docs/
│   └── SOURCES.md            # 資料來源與證據制度
├── original_es2/             # Original ES2 保存／考證／重建
│   └── races/
│       ├── README.md
│       └── headless.md
└── es2_king_expansion/       # ES2-KING 新創與重設內容
    └── races/
        ├── README.md
        └── headless.md
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

詳細工作規則請見 `AGENTS.md`；資料來源與證據規則請見 `docs/SOURCES.md`。
