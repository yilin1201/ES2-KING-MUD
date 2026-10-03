# ES2M → ES2-KING 離線導入差異盤點（2026-10-03）

> ES2M 基準：`wolfer168/es2-webmud@e93dad172cb1472dae3eba0a2d1978c12b678985`  
> ES2-KING 基準：`build/original-es2-races-phase2@2dabd2d564e843a9739a40c40ea2305fa30ab74d`  
> 範圍：地圖與出口、NPC 與互動、武功及招式、武器與裝備，共 906 個來源檔案。完整逐檔結果見同名 CSV。

## 分類規則

- **已導入**：ES2M 與 `es2m_snapshot` 同路徑 SHA 相同，且既有 Runtime overlay 明確涵蓋該路徑。
- **部分導入**：快照 SHA 相同，但 Runtime 僅選擇性套用，或尚缺完整互動／Gameplay 證據。
- **未導入**：ES2M 有檔案，但 ES2-KING 快照沒有同路徑檔案。
- **UNKNOWN**：同路徑存在但 SHA 不同；在逐檔查明差異前不判定可覆蓋。
- 本報告是離線檔案與既有套用規則盤點；不把 Static 結果宣稱為 Runtime 或 Gameplay PASS。

## 統計

| 類別 | 已導入 | 部分導入 | 未導入 | UNKNOWN | 合計 |
|---|---:|---:|---:|---:|---:|
| 地圖與出口 | 163 | 41 | 1 | 1 | 206 |
| NPC 與互動 | 70 | 75 | 1 | 0 | 146 |
| 武功及招式 | 0 | 36 | 2 | 1 | 39 |
| 武器與裝備 | 424 | 0 | 91 | 0 | 515 |
| **總計** | **657** | **152** | **95** | **2** | **906** |

## 主要差異

### 地圖與出口

- 未導入：`d/snow/bug_room.c`。
- UNKNOWN：`d/snow/sgate.c`。KING 快照已因振武軍營／老松林接線產生差異，禁止直接覆蓋。
- 41 個部分導入項目主要位於已保存但未由 overlay 整區套用的區域；仍需逐區 Runtime 與普通玩家移動驗證。

### NPC 與互動

- 已導入 70、部分導入 75。
- 未導入：`custom/wizroom/w/windstory/npc/gammer.c`。
- 「部分導入」只代表 NPC 原始檔已保存；ask／give／buy／kill 等互動及其相依物仍須個別驗證。

### 武功及招式

- 36 個技能 daemon 已保存，但現行腳本採「Runtime 缺檔才補入」，因此全部列為部分導入。
- 未導入：`daemon/skill/beast.c`、`obj/example/skill/fonxansword.c`。
- UNKNOWN：`daemon/skill/taoism-spells.c`，來源與 KING 快照 SHA 不同，需先比對差異。
- 本盤點不變更冷梅、傲梅、如來神掌、KING 武學或其他既有凍結設定。

### 武器與裝備

- 424 個 `custom/weapon`／`custom/armor`／振武物件已由既有 custom overlay 涵蓋。
- 未導入 91：hand 17、head 28、leg 9、neck 15、waist 22。
- 檔案進入 Runtime 不等於已有商店、掉落、任務或普通玩家取得途徑；取得方式維持 UNKNOWN，等待來源證據。

## 下一批建議

1. 先處理三個技能差異：`beast.c`、`fonxansword.c`、`taoism-spells.c`。
2. 裝備依同一部位集中批次導入，先做依賴與同名衝突檢查，再決定 Runtime 套用。
3. 地圖／NPC 的部分導入項目依區域執行普通玩家移動及互動測試，不以管理員帳號替代。

