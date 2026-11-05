# ES2M FIRST → ES2-KING ADDITIVE OVERLAY（正式架構指令）

## 主體與權限

- **ES2M 是遊戲內容主體**：世界／地圖、NPC、種族、職業、武功、武器、裝備、任務、經濟與原有 Driver 行為，以可追溯的 ES2M 原始資料作為實作基礎。
- **KING 是獨立擴充層**：KING 帳號權限、無極之境、冷梅莊、專屬武學與武器、神聖衣及管理指令。不得直接污染或重寫封存的 ES2M 原始碼。
- **保留來源**：目前 Docker 使用固定來源 taedlar/es2_mudlib@cc45c06af4852380e5148dad3c9d53ff06854f2c；另有 es2m_snapshot 的已收錄補充內容。未證明兩者內容相同前，不能將任何一套自動宣稱為另一套的完整替代品。
- **衝突處理**：ES2M 原始行為優先；KING 專屬 namespace 使用 KING 擴充；涉及同名共用檔案時，建立最小相容補丁並記錄差異及實際 Driver 測試。不可單憑來源名稱批次覆蓋同名檔案。
- **缺少史料**：標記 UNKNOWN／SOURCE_REQUIRED，不補造原版世界、NPC、任務或武功。

## 分層目標

1. Immutable Source：固定版本 ES2M 原始樹與來源／SHA 清冊，原始檔保持唯讀。
2. Runtime Base：從上述來源建立完整獨立 Runtime；不得僅將研究檔案視為已匯入。
3. ES2M Compatibility：補入來源已驗證的 snapshot 差異，檢查依賴、出口、繼承、指令及載入順序。
4. KING Overlay：最後套入 KING 專屬擴充，保留普通玩家原始流程。
5. Verification：檔案清冊、靜態／編譯測試、普通玩家真 Driver E2E、KING 隔離 E2E、公開 Web/WSS 與持久存檔回歸分別驗證。

## 導入優先順序

1. 地圖／房間／出口及跨區依賴。
2. NPC／商店／任務與重生依賴。
3. 武功／職業／師徒與實際 Combat。
4. 武器／裝備／物品與持久存檔。
5. KING 神聖衣與專屬系統；維持普通玩家相容性。

## 發布閘門

- 所有來源須記錄 provenance；每一批匯入需有來源→Runtime 路徑映射及依賴檢查。
- Source Inventory PASS 不等於 Runtime PASS；Render LIVE 不等於 Gameplay PASS。
- 不得為通過測試使用 KING/Admin/Wizard 代替普通玩家。
- 不重做已通過且未受修改影響的驗收；涉及共用核心檔案時，執行必要 Regression。
- PR #13 在完整驗收前保持 OPEN／NOT MERGED；不 Force Push、不做 No-op Commit、不重跑基礎設施受阻的 Actions。

## 現況與下一個實作關卡

現行 Docker 會 clone pinned taedlar/es2_mudlib，再執行 apply_race_phase2_runtime.sh 及 apply_es2_king_expansion.sh。這是「來源基底＋覆蓋層」的雛形，但尚未完成 es2m_snapshot 全量差異盤點，也未確認所有 ES2M 內容皆可玩。

先完成 pinned Source、es2m_snapshot、最終 Runtime 三方檔案／雜湊差異清冊，再針對地圖→NPC→武功→武器裝備逐批調整 overlay；未完成三方盤點前，不以無條件 cp -a 覆蓋已可玩的 Runtime。
