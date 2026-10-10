# ES2M 更新同步稽核 — 2026-10-10

## 目的與來源基準

本文件記錄 ES2M 上游更新是否已同步至 ES2-KING，不代表僅憑靜態檢查就宣稱所有玩法均已通過。

- 上游 Repository：`wolfer168/es2-webmud`
- 本次上游 HEAD：`60c12efac447d63730f953ac83ef47fdc62f7368`
- 本次範圍：2026-10-09 上游最新合併內容，尤其是 PR #26～#30 相關更新。
- King 開發分支：`build/original-es2-races-phase2`
- 保護原則：不直接覆寫 Original ES2 保存來源；已完成的 King 自訂武功與技能成長規則不得被 ES2M 整檔覆蓋；PR #13 保持 OPEN / NOT MERGED。

## 同步核對結果

| ES2M 更新 | King 落點 | 稽核結果 |
|---|---|---|
| `disable` 可停用所有已學技能，含沒有技能檔的基本技能 | `es2_king_expansion/runtime/mudlib/cmds/usr/disable.c` | 與 ES2M `main` 同一 Git blob：`e1303e0035c10f153b549c76e20059d5ed8e4d75` |
| `enable` 支援已具有效技能等級的基本技能 | `es2_king_expansion/runtime/mudlib/cmds/usr/enable.c` | 與 ES2M `main` 同一 Git blob：`233d824854baa960ec6d90019947d9e8ebe5bd7d` |
| `abandon` 驗證已學技能、重複操作與恢復訊息 | `es2_king_expansion/runtime/mudlib/cmds/usr/abandon.c` | 與 ES2M `main` 同一 Git blob：`e3c739bdf9b2890505afd87d5f3ac179d1a6cb92` |
| 私塾王懷芝：讀書點數、坐下狀態、NPC 強度及學習條件 | `es2_king_expansion/runtime/mudlib/d/snow/npc/teacher.c` | 與 ES2M `main` 同一 Git blob：`3418099cb14f82665b261634d189551244859a10`；生成 Runtime 另套用 UTF-8 回答相容修正 |
| 新版武功引擎支援學成當級獎勵 | `es2_king_expansion/runtime/mudlib/std/martial_art.c` | 與 ES2M `main` 同一 Git blob：`50fc14306147723b9a49d026efc04d96f0c0860d` |
| 七巧如意手（`seven`） | `es2_king_expansion/runtime/mudlib/daemon/skill/seven.c` | 與 ES2M `main` 同一 Git blob：`8596aa0156230e886d28a74b10973bb3f66bc528` |
| 梅影身法（`mayin`） | `es2_king_expansion/runtime/mudlib/daemon/skill/mayin.c` | 與 ES2M `main` 同一 Git blob：`4481fd68a67d3340c7ae7f3da298f657efb114e6` |
| 冷梅莊莊主梅影風與五堂鎮生成點 | `es2_king_expansion/runtime/mudlib/d/wutang/npc/may_yin_fong.c`、`crossroad.c` | NPC 已同步並保留 King 必要差異；生成點 `crossroad.c` 與 ES2M 同 blob：`d4d3269d42f83d0b219cc42c605361a20bbf7ca9` |
| 練武假人：必定命中、不閃躲／格擋、不顯示部位與傷勢，並調整 fight／kill／look | `scripts/apply_es2_king_expansion.sh` 於生成 Runtime 套用 | 已有冪等補丁及 `scripts/test_es2m_training_dummy.py` Runtime Gate；不改寫 Original 保存來源 |

## King 保留的必要差異

梅影風 NPC 檔案不與 ES2M 逐位元相同，這是刻意保留的 King 相容修正，不能用上游整檔覆蓋：

1. ES2M 上游使用 `rainner`；King 正式種族代碼是 `rainnar`，King 檔案採 `rainnar`。
2. King 依 `skill_entry_level(skill)` 及 `skill_threshold(skill, entry_level)` 計算傳授補點，避免高入門等級武功被錯誤地只補到 1 級門檻。
3. 冷梅莊既有凍結武功維持 King/KDS 基準；只同步新增的 `seven`、`mayin`，不以 ES2M 新版整檔覆蓋既有凍結檔案。

## 驗證方式與證據邊界

Dockerfile 已將以下測試接入生成 Runtime 建置流程：

- `python3 scripts/test_es2m_training_dummy.py --runtime /opt/es2-king/runtime`
- `python3 scripts/test_es2m_skill_commands.py --runtime /opt/es2-king/runtime`
- `python3 scripts/test_es2m_cold_plum_overlay.py --runtime /opt/es2-king/runtime`

這些閘門驗證來源／Expansion／生成 Runtime 的檔案一致性與關鍵契約。它們本身不取代 Neolith Driver 的完整遊戲內 E2E；只有取得相應真實 Runtime marker 才能宣稱玩法驗收 PASS。

## 結論

截至 ES2M 上游 HEAD `60c12ef`，本次核對的 2026-10-09 更新已在 King 具備相應來源或生成 Runtime 補丁。未發現需要直接將上游檔案整份覆寫到 Original ES2 的缺口。下一步以專用靜態同步工作流程重跑現有測試閘門，並保持 PR #13 開啟、不合併。
