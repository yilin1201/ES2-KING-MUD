# ES2M 李家村出口修正紀錄 — 2026-10-13

## 失敗證據

Oracle Docker build 的第 53/83 步通過靜態拓撲檢查，但 Runtime topology gate 顯示六個出口未進入生成的 Runtime。這代表「拓撲靜態檢查通過」不能取代「生成 Runtime 出口驗證」。

## 資料來源優先順序

- **主來源：** `wolfer168/es2-webmud` 的 `main`，本次核對 HEAD：`ee12e717e2d3d88728607a01c2c2f1d634bf9616`。
- **地圖連接判定：** 優先依 ES2M `source/upstream/mudlib/d/lee/LEE_TOPOLOGY.json` 的明確拓樸登錄；房間 LPC 若與拓樸衝突，視為舊資料／實作不一致，修正 KING 工作快照以符合拓樸，不反向修改上游。
- **ES2-KDS：** 僅作交叉比對資料，不得取代 ES2M 主來源。
- **ES2-KING 自訂內容：** 只保留於 KING 工作快照／Expansion，必須標示重建或擴充，不得冒充上游原始資料。

## 本次修正

| 房間 | 方向 | 目標 |
|---|---|---|
| `square_s` | south | `pawnshop` |
| `square_c` | east | `watermelon_n1` |
| `watermelon_n1` | west | `square_c` |
| `pawnshop` | north | `square_s` |
| `watermelon_s3` | east | `creek` |
| `creek` | west | `watermelon_s3` |

已同步修改六個 ES2M snapshot LPC 房間檔與 `LEE_TOPOLOGY.json`，使來源出口和拓撲登錄一致。只調整出口關係，不改寫房間描述、NPC、物件或其他遊戲規則。

## 驗證邊界

- GitHub 來源檔核對：已確認六個房間檔與拓撲登錄存在對應出口。
- Oracle Docker Runtime gate：需在拉取本次最新分支後重新建置才能確認；尚未宣稱 PASS。
- 候選映像只用於建置驗證，不替換現行遊戲容器。
- PR #13 保持 OPEN / NOT MERGED。
