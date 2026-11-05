# GitHub Workflows 分類索引

> Cleanup 基準：`c1fc52dd5a938b2100c91cfabdbd9c59593f2fdc`  
> Actions 目前為 ACTIONS-INFRA-BLOCKED；本次沒有執行或 rerun。

## Active Regression / Release Gates（8）

- `.github/workflows/es2-king-m26-admin-creation.yml`
- `.github/workflows/es2-king-m27-wuji-realm.yml`
- `.github/workflows/es2-king-m28-martial.yml`
- `.github/workflows/es2-king-m29-canon.yml`
- `.github/workflows/es2-king-m30-alpha.yml`
- `.github/workflows/original-es2-driver-build.yml`
- `.github/workflows/original-es2-m25-release-candidate.yml`
- `.github/workflows/roadmap-m21-m30.yml`

## Archived Milestone Workflows（25）

- `docs/archive/workflows/original-es2-m10-race-baseline.yml`（原：`.github/workflows/original-es2-m10-race-baseline.yml`）
- `docs/archive/workflows/original-es2-m11-class.yml`（原：`.github/workflows/original-es2-m11-class.yml`）
- `docs/archive/workflows/original-es2-m11-school-static.yml`（原：`.github/workflows/original-es2-m11-school-static.yml`）
- `docs/archive/workflows/original-es2-m12-skill.yml`（原：`.github/workflows/original-es2-m12-skill.yml`）
- `docs/archive/workflows/original-es2-m12-study-runtime.yml`（原：`.github/workflows/original-es2-m12-study-runtime.yml`）
- `docs/archive/workflows/original-es2-m12-study-static.yml`（原：`.github/workflows/original-es2-m12-study-static.yml`）
- `docs/archive/workflows/original-es2-m13-force-runtime.yml`（原：`.github/workflows/original-es2-m13-force-runtime.yml`）
- `docs/archive/workflows/original-es2-m13-force-static.yml`（原：`.github/workflows/original-es2-m13-force-static.yml`）
- `docs/archive/workflows/original-es2-m14-apprentice-runtime.yml`（原：`.github/workflows/original-es2-m14-apprentice-runtime.yml`）
- `docs/archive/workflows/original-es2-m14-apprentice-static.yml`（原：`.github/workflows/original-es2-m14-apprentice-static.yml`）
- `docs/archive/workflows/original-es2-m15-lengmei-runtime-gate.yml`（原：`.github/workflows/original-es2-m15-lengmei-runtime-gate.yml`）
- `docs/archive/workflows/original-es2-m15-lengmei-static.yml`（原：`.github/workflows/original-es2-m15-lengmei-static.yml`）
- `docs/archive/workflows/original-es2-m16-npc-item-runtime-gate.yml`（原：`.github/workflows/original-es2-m16-npc-item-runtime-gate.yml`）
- `docs/archive/workflows/original-es2-m16-npc-item-static.yml`（原：`.github/workflows/original-es2-m16-npc-item-static.yml`）
- `docs/archive/workflows/original-es2-m17-world-runtime-gate.yml`（原：`.github/workflows/original-es2-m17-world-runtime-gate.yml`）
- `docs/archive/workflows/original-es2-m18-quest-runtime-gate.yml`（原：`.github/workflows/original-es2-m18-quest-runtime-gate.yml`）
- `docs/archive/workflows/original-es2-m19-lifecycle.yml`（原：`.github/workflows/original-es2-m19-lifecycle.yml`）
- `docs/archive/workflows/original-es2-m20-alpha.yml`（原：`.github/workflows/original-es2-m20-alpha.yml`）
- `docs/archive/workflows/original-es2-m21-world-content.yml`（原：`.github/workflows/original-es2-m21-world-content.yml`）
- `docs/archive/workflows/original-es2-m22-npc-item.yml`（原：`.github/workflows/original-es2-m22-npc-item.yml`）
- `docs/archive/workflows/original-es2-m23-core-gameplay.yml`（原：`.github/workflows/original-es2-m23-core-gameplay.yml`）
- `docs/archive/workflows/original-es2-m24-data-integrity.yml`（原：`.github/workflows/original-es2-m24-data-integrity.yml`）
- `docs/archive/workflows/original-es2-m4-combat.yml`（原：`.github/workflows/original-es2-m4-combat.yml`）
- `docs/archive/workflows/original-es2-m5-races.yml`（原：`.github/workflows/original-es2-m5-races.yml`）
- `docs/archive/workflows/original-es2-race-phase2.yml`（原：`.github/workflows/original-es2-race-phase2.yml`）

## 保存規則

- Archive 保留 Workflow 原文與歷史追溯價值，但不再由 GitHub Actions 自動觸發。
- 對應 `scripts/test_*` 全數保留，測試能力未刪除。
- Current Release Gate 不依賴 Archived Workflow。
