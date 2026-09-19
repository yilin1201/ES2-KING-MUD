# M30 CURRENT STATUS — 目前唯一即時狀態入口

> Status Date：2026-09-19  
> Branch：`build/original-es2-races-phase2`  
> 本文件是 Current Status（目前狀態），不是歷史測試報告。  
> PR #13：OPEN / NOT MERGED。M31：未開始。

## 1. 已由 Public Device 實際驗收

| 項目 | 狀態 |
|---|---|
| Render 公開 HTTPS 入口 | PASS |
| iPhone → WebTelnet → WSS → Bridge → Neolith | PASS |
| UTF-8 中文／Mobile 顯示 | PASS |
| KING ID 公開搶註冊保護 | PASS |
| KING Claim HEX-V1 Transport | PASS |
| KING Claim Authentication | PASS |
| Original Password Setup | PASS |
| Email Flow | PASS |
| Original Race Selection | BLOCKER / 待最新 CR 修正 Public 驗收 |

## 2. Race 最新修正

`webtelnet/public/character-input.mjs`

- `human` → CR（Carriage Return／回車），確認目前 Original 游標項目。
- `avatar` → KEY_DOWN（向下鍵）→ 等 Original 重畫 → CR。
- Gender 維持 F / M / N。
- Confirm 維持 Y / N。

此修正只改 WebTelnet Compatibility Layer（網頁相容轉換層），沒有改 Original ES2 保存原始碼。

## 3. 本機既有 PASS、Public 待最終驗收

- KING Owner Authorization／顯示 `(admin)`
- `kingcreate`
- `kingrealm`
- `kingmartial`
- `kingcanon`
- save / quit / relogin
- 普通玩家無法取得 KING Owner 權限

## 4. 已知 Hosting 限制

Render Free 沒有 Persistent Disk（永久磁碟）。Repository 的持久化架構本身已規劃 `ES2_SAVE_DIR`，但目前免費 Hosting 重新部署仍可能遺失玩家／KING Runtime Save。這是 Hosting limitation，不等同 Race bug。

## 5. 現在禁止重複執行的項目

除非相關程式被修改，否則不要重新診斷 Claim Token transport、Claim Authentication、Password Setup、Email Flow、KING ID Reservation。

目前最小下一步只有：**部署最新 Head → Public Device 驗證 human / avatar 是否能進入下一個 Original 創角狀態。**

## 6. 歷史文件定位

以下保留作 Historical Evidence（歷史證據），不可單獨覆蓋本文件：
- `M30_ALPHA_FINAL_AUDIT.md`
- `M30_PLAYABLE_ALPHA_ENTRY.md`
- `M30_DEPLOYMENT_READINESS.md`
- `original_es2/runtime/*`
- `es2_king_expansion/runtime/*_result.md`

Original ES2 Evidence Registry 與 Source Manifest 仍各自保持其證據效力。
