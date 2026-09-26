# M30 CURRENT STATUS — 目前唯一即時狀態入口

> Status Date：2026-09-25  
> Branch：`build/original-es2-races-phase2`  
> Post-Neon Audit Baseline：`15e27c606886f1b96c2bbe5bda037989c767becb`  
> 本文件是 Current Status（目前狀態），不是歷史測試報告。  
> PR #13：OPEN（開啟） / NOT MERGED（未合併）。M31：未開始。

## 1. Game Completion（遊戲完整可玩性）

| 項目 | 實際 Runtime 狀態 |
|---|---|
| Full Driver Journey（完整真實 Driver 流程） | PLAYABLE PASS（實際可遊玩驗收通過） |
| NPC interaction（非玩家角色互動） | RUNTIME PASS（真實執行環境通過） |
| Economy / Shop（經濟／商店） | RUNTIME PASS（Original 貨幣扣款、Vendor 交貨與 Inventory 餘額通過） |
| Items / Equipment（物品／裝備） | RUNTIME PASS（真實執行環境通過） |
| Combat（戰鬥） | RUNTIME PASS（真實執行環境通過） |
| Skills（技能） | RUNTIME PASS（真實執行環境通過） |
| School / Apprentice（門派／師徒） | RUNTIME PASS（真實執行環境通過） |
| Save / Quit / Relogin（存檔／離開／重新登入） | RUNTIME PASS（真實執行環境通過） |
| Quest（任務） | UNKNOWN（Original 證據不足，不補造） |

實際完成流程：

`Connect → Login → Character → Enter World → Look → Score → Inventory → Movement → NPC → Economy/Shop → Items/Equipment → Combat → Skills → School/Apprentice → Save → Quit → Relogin`

因此目前正式判定：**GAME COMPLETION = PLAYABLE PASS（遊戲完整可玩性通過）**。

## 2. Evidence 與 Runtime 分層

- Evidence（證據）記錄 Original ES2 的來源可信度與尚未確認內容。
- Runtime（執行環境）記錄真正由 Neolith Driver（Neolith 遊戲執行引擎）執行的結果。
- Full Driver Runtime Gate（完整 Driver 執行關卡）已在上述 Evidence Head 實際通過。
- Runtime PASS 不會把 Quest 或其他缺少 Original 史料的項目自動提升為歷史 CONFIRMED（已由史料直接證實）。

## 3. Public Compatibility / Render

| Release Gate（發布關卡） | 狀態 |
|---|---|
| Primary Public Runtime（主要公開執行環境） | `ES2-KING-MUD`／https://es2-king-mud.onrender.com |
| Repository / Render Sync（版本同步） | PASS（測試通過）：Post-Neon baseline 公開 `/health` 的 `build_commit` = `15e27c606886f1b96c2bbe5bda037989c767becb`；後續提交以部署健康檢查為準 |
| Public Runtime Chain（公開執行鏈） | PASS（測試通過）：HTTPS → WSS → Bridge → Neolith；`web`、`bridge`、`neolith` 均為 `true` |
| Public Race Runtime（公開種族執行流程） | PASS（測試通過）：真實公開 WSS 完成 Account → Password → Email → Race → Gender → Character → Enter Game |
| Public Device Acceptance（公開裝置驗收） | PASS（Owner 已確認 iPhone Public Runtime） |
| Public Compatibility（公開環境相容性） | PASS（Web Client、公開 WSS 與 iPhone Entry 已通過） |
| Temporary Validation Service（臨時驗證服務） | `es2-king-alpha`：TEMP / UNCHANGED（臨時／未修改，不是主線） |

Public Gate 是獨立 Release Gate，不回頭阻塞已取得的 Game Completion Runtime 證據。`heros-mud-rebuild` 屬另一獨立專案，未修改。

## 4. Permanent Persistence

Render Free 的 ephemeral filesystem 限制已由 Neon durable backing store 解決。Neolith 仍先寫入 mudlib 實體 `data/`，再以 checksummed opaque snapshot 同步 Neon；新容器會在 Driver 接受登入前還原。KING 已完成 Render New Container 的 Cross-Container Restore，正式判定 PASS。

## 5. 歷史文件定位

以下保留作 Historical Evidence（歷史證據），不可單獨覆蓋本文件：
- `docs/history/m30/M30_ALPHA_FINAL_AUDIT.md`
- `docs/history/m30/M30_PLAYABLE_ALPHA_ENTRY.md`
- `docs/history/m30/M30_DEPLOYMENT_READINESS.md`
- `original_es2/runtime/*`
- `es2_king_expansion/runtime/*_result.md`

Original ES2 Evidence Registry（證據登錄表）與 Source Manifest（來源清單）仍各自保持其證據效力。
