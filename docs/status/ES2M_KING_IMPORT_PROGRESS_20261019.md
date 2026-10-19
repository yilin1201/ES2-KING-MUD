# ES2M → ES2-KING 匯入進度 — 2026-10-19

## 本輪來源基準

- ES2-KING Repository：`yilin1201/ES2-KING-MUD`
- 工作分支：`integration/es2m-audit-import-20261017`
- 本輪最新提交：`d1daea2731c4f639e6226c87949e3c89234e6da7`
- 新 ES2M 固定來源：`63e932a2e46aa745a741df14e108df76bcd30f84`
- 新來源 manifest：`docs/status/ES2M_SOURCE_SYNC_MANIFEST_20261019.json`
- manifest 規模：1,709 檔；963 與舊快照相同、163 修改、583 新增、18 舊快照獨有；764 個路徑需要審查。
- 舊來源 pin `71693beb79ced81d51719ea1ccf7c02c641ca9b0` 保留，未以新 SHA 覆蓋。

## 已寫入 KING Repository 的更新

| 項目 | Commit | 實際狀態 |
|---|---|---|
| 2026-10-19 橋隱區安全匯入器 | `740f5fbc` | 已新增；只處理 manifest 標記為新檔的 `d/qiaoyin/*.c`，逐檔驗證 Git blob SHA，不覆蓋既有 Runtime。 |
| 橋隱區匯入單元測試 | `e5b076a9` | 已新增；涵蓋來源 pin、SHA、同名衝突、未解相依及保留既有 Runtime 相依。 |
| Docker build 匯入接線 | `80934af0` | 已加入新 pin 的獨立匯入步驟，舊 2026-10-17 匯入步驟保留。 |
| 顯示名稱 E2E 診斷 | `60d0d007`、`ff38f859` | 已加入送出位元組十六進位與失敗時最近 512 字元輸出。 |
| ES2M 帳號規則 A 靜態閘門 | `06041063`、`d1daea27` | 已將數字帳號測試改為驗證 ES2M 英數帳號與顯示名稱 1–18 字元規則，並接入 Docker build。 |

## 尚未宣稱完成的項目

- 新橋隱區匯入器、Docker build、Runtime 與 E2E **尚未實際執行驗證**；以上是程式與建置流程已寫入 Repository，不代表遊戲已通過。
- 新橋隱區匯入器只有在所有候選來源 SHA、同名衝突與字面相依均通過時才會複製檔案；任何未知相依或衝突都應阻止建置，不得放寬條件。
- 新版來源目前只接入獨立的橋隱區增量匯入；尚未把 1,709 個來源檔案整批匯入 Runtime。
- 新增技能、煉丹／藥物、戰鬥核心、UTF-8、角色生命週期維持 HOLD。
- `d/snow/npc/teacher.c` 及 KING 同名自訂檔案必須保留 KING 版本。
- ES2M 的 `feature/user/input.c` 改變登入確認提示、性別選單與行尾處理；KING 網頁解析器是否改為相容新版 UI，仍需使用者在路線 A／B 間決定。本輪未擅自修改 `webtelnet/public/character-input.mjs`。
- `admin.c` 的 `skill_level` 修改仍待使用者決定接受或還原。

## 固定保護規則

- PR #13 維持 OPEN / NOT MERGED。
- 不修改 `build/original-es2-races-phase2)。
- 不部署 Render。
- 不刪除／跳過測試，不將靜態檢查或本機沙箱結果宣稱為 Runtime／GitHub Actions PASS。
- 新舊來源與 Original ES2、ES2M、ES2-KING Expansion 分層保存。
