# M30 ES2-KING Alpha 驗收結果

`WORK-LOCAL PASS`（Work 雲端本機驗證通過）。

## Gate 結果

```text
M30 ALPHA STATIC PASS／M1-M30 矩陣、完成證據與邊界完整。
M30 ALPHA RUNTIME PASS／Original 核心與 M26-M29 Expansion overlay 相容。
M30 TODO/FIXME/STUB SCAN：已執行；結果以實際掃描檔為準。
M30 FULL REGRESSION：已執行可取得的 M1-M29 repository test scripts，結果記錄於本文件後續。
Driver Build：PASS（Neolith dev-linux）。
Driver Boot：PASS（Expansion Runtime 真實啟動並載入）。
```

## Full Regression 實際輸出

```text
M19 LIFECYCLE STATIC PASS
M19 LIFECYCLE RUNTIME GATE PASS
M20 ORIGINAL ALPHA STATIC PASS
M21 WORLD STATIC PASS
M21 WORLD RUNTIME PASS
M22 NPC ITEM STATIC PASS
M22 NPC ITEM RUNTIME PASS
M23 CORE GAMEPLAY STATIC PASS
M23 CORE GAMEPLAY RUNTIME PASS
M24 DATA INTEGRITY STATIC PASS
M24 DATA INTEGRITY RUNTIME PASS
M25 RELEASE CANDIDATE STATIC PASS
M25 RELEASE CANDIDATE RUNTIME PASS
M26 KING ADMIN STATIC PASS／RUNTIME PASS
M27 WUJI REALM STATIC PASS／RUNTIME PASS
M28 MARTIAL STATIC PASS／RUNTIME PASS
M29 CANON STATIC PASS／RUNTIME PASS
M30 ALPHA STATIC PASS／RUNTIME PASS
```

M1～M18 的正式結果文件、工作流程與測試檔已納入 Completion Matrix；本次 Work 環境可直接取得並重跑的回歸腳本為 M19～M30，M1～M18 保留既有已提交驗收證據，未將不可直接取得的舊執行檔輸出冒稱為本次重跑結果。

## Alpha Smoke Test／Alpha 冒煙測試

M25 已完成真實 Original 玩家旅程：建立角色、human、commoner、look、score、inventory、help、west／east、save、quit、重新登入與 score persistence；本次 M30 在同一 Driver Runtime 追加 Expansion 管理員旅程：

```text
kingcreate list：PASS
kingcreate /obj/bottle：PASS（未登錄路徑拒絕）
kingcreate creation_mark：PASS
kingrealm：PASS
down → /d/snow/square：PASS
kingmartial yijinjing 300：PASS → 黑級無極境
kingmartial batian ji：PASS
kingcanon huntian 10：PASS → 玄宇宙
kingcanon rulai 11：PASS → 天舞梵輪・萬相歸墟／阿賴耶識・歸墟神輪
kingcanon turn 4：PASS → 破八識
超界與未知設定：PASS（正確拒絕）
```

## Compatibility／相容性

Original 的種族、職業、屬性、技能、study／learn、force／exert、師徒、戰鬥、Save／Load、重登及 200 級技能上限均保留；Expansion 300 級易筋經、渾天十層、如來十一式與佛兵索引均位於 `es2_king/` 命名空間，不覆寫 Original。

## Known limits／已知限制

M18 任務完整歷史鏈、M28／M29 戰鬥數值與部分歷史內容維持 `UNKNOWN`。GitHub Actions：`ACTIONS-INFRA-BLOCKED`，不 rerun、不增加 Spending Budget、不宣稱 Actions PASS。

PR #13：Open；Merge：禁止且未執行。
