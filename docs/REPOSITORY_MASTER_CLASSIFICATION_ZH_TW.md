# ES2-KING Repository Master Classification — Owner Edition

> Branch: `build/original-es2-races-phase2`  
> PR #13: **OPEN / NOT MERGED**  
> 目的：把現有 Repository 重新整理成「一眼知道去哪裡找資料」的主索引。  
> 原則：本輪採**邏輯重整優先**，不大量搬動 Runtime/Workflow 路徑，避免破壞既有測試。

## 0. 專案五層模型

所有資料統一歸入五層：

1. **CURRENT** — 現在做到哪裡、下一個 Gate。
2. **ORIGINAL EVIDENCE** — 東方故事2原作／歷史實機／封存來源。
3. **ORIGINAL RECONSTRUCTION** — 根據 Evidence 重建的 Original Runtime／測試。
4. **ES2-KING CANON & EXPANSION** — Owner 正式設定與新增內容。
5. **ENGINEERING / RELEASE** — scripts、WebTelnet、Docker、Render、Workflows。

禁止跨層誤判：Evidence 不等於 Runtime PASS；Historical PASS 不等於 Current PASS；Expansion 不回填成 Original 史實。

## 1. Owner 最短閱讀路徑

`README.md`
→ `docs/status/CURRENT_M30_STATUS.md`
→ `docs/status/GAME_COMPLETION_MATRIX.md`
→ 本文件
→ `original_es2/research/EVIDENCE_MASTER_INDEX.md`
→ 任務相關 Runtime/Test。

## 2. CURRENT — 現況控制

- `docs/status/CURRENT_M30_STATUS.md`：Public/Release 現況。
- `docs/status/GAME_COMPLETION_MATRIX.md`：Game Completion Track 現況。
- `ROADMAP_M0_M30.md`：鎖定 Roadmap；不建立 M31。
- `docs/history/m30/*`：歷史驗收，只供追溯，不代表現在。

**治理修正：** Public Compatibility 與 Game Completion 是兩條獨立 Gate。Current 文件必須同時指向兩者，不能再讓舊 Race blocker 看起來像唯一開發主線。

## 3. ORIGINAL EVIDENCE — 原作證據

### 3.1 Source / Archived Source
- `original_es2/source_manifest.md`
- Google Sites 系列 Evidence。
- Race / Class / Skill / Study / Martial / Apprentice 等 source-backed Evidence。

### 3.2 Historical Gameplay Evidence
- `pixnet_clert2201_historical_gameplay_evidence.md`
- `mei_yingfeng_skills_runtime_evidence.md`
- `es2_actual_login_character_runtime_evidence_part1.md`

### 3.3 Registry
- NPC / Item：M16、M22。
- World：M17、M21。
- Quest：M18。
- Lifecycle：M19。
- Master：`EVIDENCE_MASTER_INDEX.md`
- Conflict：`EVIDENCE_CONFLICT_REGISTER.md`
- Runtime usability：`EVIDENCE_RUNTIME_USABILITY_MATRIX.md`

### 3.4 Evidence Status
優先級：
`Original Source > Archived Source > Archived Gameplay Record > Player Record > Reconstruction`

## 4. ORIGINAL RECONSTRUCTION — 重建層

### Data
- `original_es2/data/historical_race_registry.json`
- `original_es2/data/m15_lengmei_mei_yingfeng.json`

### Domain
- `characters/`
- `races/`
- `systems/`
- `ui/`

### Runtime Results
- `original_es2/runtime/`：M2～M25 歷史 Runtime Result。

### Tests / Gates
- `original_es2/tests/`
- `scripts/test_mXX_*`

注意：Result 文件只是「那次執行」；最新 PASS 必須由 Current Track 或新 Runtime 證據確認。

## 5. ES2-KING CANON / EXPANSION

### Canon / Design
- `king_library/`：易筋經、霸天煉體訣、渾天寶鑑、如來神掌、人物、神兵。
- `es2_king_expansion/canon/`
- `es2_king_expansion/characters/`
- `es2_king_expansion/martial_arts/`

### Runtime Overlay
- `es2_king_expansion/runtime/mudlib/`
  - KING daemons
  - KING commands
  - 無極之境
  - creation mark
  - `lengmei_d.c`：明鏡止水／六式隨機攻擊 Project Canon Runtime

### Research / Historical Results
- `es2_king_expansion/research/`：M26～M30設計邊界。
- `es2_king_expansion/runtime/*_result.md`：歷史執行結果。

## 6. 冷梅／梅影風專區 — 新 Evidence 合併視圖

### Original / Historical CONFIRMED
- 寒梅心法 — `hainmay force`
- 傲梅暗劍訣 — `advance_lunmay`
- 冷梅劍法 — `lunmay`
- 梅影身法 — `mayin`
- 七巧如意手 — `seven`
- `acquire seven from may`：梅影風傳授七巧如意手的實機關係。
- PIXNET 另支持冷梅進階、寒霜三千里、寒梅玉珮、任務鏈等 Historical Gameplay Evidence。

### Project Canon
- 冷梅心法：舊 Project Naming；目前與實機「寒梅心法」不一致。
- 明鏡止水：特殊戰鬥狀態，不是單次攻擊。
- 狀態 ON 後自動隨機六式：梅二方劍、梅四方劍、梅八方劍、愛霜恨雪、寒霜三千里、傲梅暗劍訣。
- 傷害／耗精／Buff／權重未有足夠 Evidence 者維持 UNKNOWN。

### 必須處理的名稱治理
Historical/Original 顯示「寒梅心法」已有雙重 Evidence。後續 Runtime 應以歷史實機名稱為正名；若保留「冷梅心法」，只能作 ES2-KING compatibility alias，不能改寫 Original Evidence。

## 7. ENGINEERING

### Runtime build
- `bootstrap_original_es2.sh`
- `apply_es2_king_expansion.sh`
- `apply_race_phase2_runtime.sh`

### Game Completion
- `bootstrap_game_completion_character.sh`
- `test_game_completion_journey.sh`
- `test_game_completion_full_driver_e2e.sh`
- `test_game_completion_full_driver_e2e.mjs`
- `audit_game_completion_runtime.sh`
- `run_game_completion_track.sh`

### Public Browser
- `webtelnet/`
- character input compatibility
- KING claim transport
- WebSocket/Telnet bridge

### Deploy
- Dockerfile
- render.yaml
- persistence/start/healthcheck scripts

### Workflows
`.github/workflows/` 只保留 8 份現行 Regression／Release Gate；已完成里程碑的 25 份 Workflow 原文封存於 `docs/archive/workflows/`。對應測試 scripts 全數保留。GitHub Actions infrastructure 不作 Game Completion blocker。

## 8. Game Completion 主線

現階段真正 Completion Journey：

`Connect/Login → Character → Enter World → NPC → Items/Equipment → Combat → Skills → School/Apprentice → Save/Quit/Relogin`

Runtime Evidence Head `07b865ce4a8ac9689e64580cc605f045e5cea0aa` 已完成**單一 Neolith Full Driver Journey（完整真實 Driver 流程）**：

`Connect → Login → Character → Enter World → Look → Score → Inventory → Movement → NPC → Items/Equipment → Combat → Skills → School/Apprentice → Save → Quit → Relogin`

其中 NPC、Items / Equipment、Combat、Skills、School / Apprentice、Save / Quit / Relogin 全部為 RUNTIME PASS（真實執行環境通過），因此 **GAME COMPLETION = PLAYABLE PASS（遊戲完整可玩性通過）**。

Quest 因 Original Evidence 不足維持 UNKNOWN，不虛構 Canon。Public Compatibility 與 Render 為獨立發布／部署關卡，本階段維持 PENDING / NOT TESTED（待驗證／未測試）。

新取得的實機影片與 Skills 截圖仍應逐步轉成 Journey expected input/output；此 Evidence 工作用於提升可追溯性，不撤銷已取得的 Runtime PASS。

## 9. 文件命名／新增規則

新資料先判斷層級：
- 原作／歷史來源 → `original_es2/research/`
- Original 結構化資料 → `original_es2/data/`
- Original Runtime Result → `original_es2/runtime/`
- ES2-KING 正式設定 → `es2_king_expansion/` 或 `king_library/`
- 可執行 overlay → `es2_king_expansion/runtime/mudlib/`
- 工程測試 → `scripts/`
- Current → `docs/status/`
- Historical → `docs/history/`

禁止再把 CURRENT、Evidence、Result、Plan 混放後用檔名猜狀態。

## 10. 後續實體重構原則

`scripts/` 與 Runtime 路徑維持原位，避免 path regression；已完成里程碑 Workflow 已移出自動執行目錄並封存。

Game Completion Full Driver 已達 PLAYABLE PASS；只有在 Owner 另行授權實體重構後，才考慮第二階段整理：
- scripts 分 build/test/deploy；
- workflows 分 original/expansion/release；
- research 新 Evidence 依 source/gameplay/registry 分子目錄。

實體搬移前必須先建立引用圖並一次修完 path，不做半套搬遷。
