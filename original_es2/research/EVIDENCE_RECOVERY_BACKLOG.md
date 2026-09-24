# Original ES2 Evidence Recovery Backlog（證據補完待辦）

> 第四階段 4F。依 4E Runtime Usability Matrix（實作可用性矩陣）建立後續考證順序。此清單不把 UNKNOWN 自動升級成 Original 事實。

## P0 — 會直接阻擋 Original 核心重建

| 項目 | 目前狀態 | 要找的直接證據 | 完成條件 |
|---|---|---|---|
| Quest 任務完整鏈 | SOURCE_REQUIRED | quest daemon、NPC trigger、flag/save、completion/reward LPC | 至少一條完整 Original 任務鏈可逐檔追溯 |
| 人類族 Original ID | SOURCE_PENDING | Original race selection、race daemon/chinese mapping 或可靠歷史實機 | 確認正式 ID；在此之前禁止把 `human_clan` 當 Original ID |
| 遺失 Race initializer | PARTIAL | Original race daemon / initialize / advance_level | 已保存種族可分別鎖定初始化與升級行為 |

## P1 — 影響世界與內容完整度

| 項目 | 目前狀態 | 要找的直接證據 | 完成條件 |
|---|---|---|---|
| 冷梅莊 Runtime | REFERENCE_ONLY | room/NPC/skill LPC 或可信 archive | path、出口、NPC clone 可交叉核對 |
| 梅影風／劉乙忘玄 | REFERENCE_ONLY | NPC LPC／歷史完整資料 | 身分、path、技能/裝備只登錄直接支持欄位 |
| Google Sites 國家地圖 → Runtime | ARCHIVED_SOURCE | 對應 room tree／舊 source archive | 地名與 Runtime path 建立可追溯映射 |
| 七職業遺失 Daemon | PARTIAL | scholar/taoist/thief/alchemist/bonze/soldier 等 Original Source | 每個 Class 的實際 daemon 或可靠版本證據 |

## P2 — 可延後，不阻擋已確認 Engine

| 項目 | 狀態 | 原則 |
|---|---|---|
| blackteeth 業力 3/5 | CONFLICT | 保留版本差異，不選單一歷史真值 |
| yaksa 業力 35/30 | CONFLICT | 保留版本差異，不選單一歷史真值 |
| 刑天／形天 | VERSION/CANON CONFLICT | Original 原文保留「形天」證據；專案主名稱依既定 Canon 使用「刑天」 |
| 死亡懲罰／輪迴／轉生 | UNKNOWN | 未取得直接 Source 前不補造 |

## 搜尋順序

1. Repository 現存 Original/legacy source。
2. 已保存 Archive、Google Sites、歷史截圖／實機紀錄。
3. 已知 upstream commit/tree。
4. 玩家紀錄只作線索，不單獨升級為 Source。
5. 找不到即維持 UNKNOWN/SOURCE_PENDING，不用 Reconstruction 填空。

## GitHub Actions 異常註記

2026-09-19 在 4E 文件提交後，PR 事件自動產生多個 GitHub Actions（GitHub 自動測試流程）run，皆在約 5–10 秒內結束並標示 failure；例如 M30 Alpha run `35439403202`、M21-M30 Roadmap run `35439403256`、Driver Build run `35439403040`。本階段只有 docs 變更，且既定零付費環境已知存在 Actions infrastructure block（基礎設施阻擋）；因此不 rerun、不提高 Budget，也不把這批 failure 當成 4E 文件內容失敗。若未來取得可用 job log 顯示實際程式錯誤，再另案修正。


## 2026-09-25 Gap Auto-Comparison 更新

依 `CURRENT_GAME_DATA_GAP_EVIDENCE_COMPARISON.md`：

- P1「梅影風／劉乙忘玄」拆分：梅影風的身分、冷梅五項 skill ID、裝備名稱、家族／師門關係已有多源 Evidence，資料層缺口大幅收斂；**NPC LPC path、HP、完整 set_skill/map_skill 仍 SOURCE_REQUIRED**。劉乙忘玄新增「厭火族／哭笑門門主」Archived Source 支持，但 Runtime path/數值仍缺。
- P1「冷梅莊 Runtime」維持 SOURCE_REQUIRED：新 Evidence 沒有提供可驗證 room/NPC LPC path。
- P2「死亡懲罰／輪迴／轉生」拆分：城隍爺 `register` 與死亡→陰間→輪迴概念已升為 CONFIRMED_TEXT；實作、費用、旗標、公式仍 UNKNOWN。
- P2「刑天／形天」新增 Vovo Archived Source 的「形天族」人物例，強化歷史用字存在性，但不解消版本／專案 Canon 分層。
- P0 人類族 Original ID、遺失 Race initializer，以及 blackteeth/yaksa 業力衝突均未被新 Evidence 解決。

Playable Track 不等待上述歷史缺口全部解決；真正 blocker 仍是既有 Full Driver Journey 的 Runtime execution proof。
