# ES2-KING 普通玩家／存檔／裝備驗證覆蓋矩陣

> 此文件只盤點可見的測試入口與證據界線，不宣稱本輪已執行 Runtime、公開 Gameplay 或手機實測。與 Work 的 ES2M 匯入、NPC、防具及通用模擬器主功能修改分開維護。

| 項目 | 現有測試入口 | 本輪獨立檢查 | 驗收界線 |
| --- | --- | --- | --- |
| 公開部署版本一致性 | `scripts/test_m30_deployment_smoke.mjs` | `scripts/test_player_persistence_evidence_static.mjs` | 須核對指定完整 Build SHA；僅讀取程式不代表公開部署已驗收 |
| 外部普通玩家連線 | `scripts/test_public_player_session_smoke.mjs`、`scripts/test_public_player_acceptance.mjs` | 靜態檢查外部 HTTPS/WSS 及非管理員證據標記 | 實際 PUBLIC PASS 需連線並取得新證據，不得以 localhost、KING、admin 或 wizard 替代 |
| 普通玩家建立與操作 | `scripts/test_player_open_alpha_e2e.mjs`、`scripts/test_original_player_creation_e2e.mjs` | 靜態檢查 E2E 的 player 權限斷言 | 建角、移動、戰鬥、背包及重新登入必須分別有 Runtime 證據 |
| 本機存檔、程序重啟 | `scripts/test_m30_persistence_paths.sh` | 靜態檢查離線測試取消 DATABASE_URL、包含同步及程序重啟 | 隔離環境測試不等於 Neon 永久保存或 Render 跨部署驗證 |
| Neon 持久化 | `scripts/prepare_es2_persistence.sh`、`scripts/sync_es2_persistence.sh` | 靜態檢查 download/upload 入口 | 真正 Neon 測試須有隔離資料庫、跨程序／部署前後資料證據 |
| KING 武器登入裝備 | `scripts/test_king_weapon_loadout_static.sh`、`scripts/test_king_weapon_runtime_e2e.mjs` | 與普通玩家測試隔離，不使用 KING 證據取代玩家驗收 | 五件武器、登入 UNWIELD、雙劍／雙手劍及 save→quit→relogin 需各自核對 |
| 通用武功模擬器 | `scripts/test_martial_arts_simulator.mjs`、`scripts/test_martial_simulator_edge_cases.mjs` | 12 式、特攻一次、單式／連續切換及外框邊界 | 靜態文字 PASS 不等於 MUD 武功 Runtime 或手機 UI PASS |

## 不重複下載的建議離線命令

```bash
node scripts/test_martial_arts_simulator.mjs
node scripts/test_martial_simulator_edge_cases.mjs
node scripts/test_player_persistence_evidence_static.mjs
bash scripts/test_m30_persistence_paths.sh
bash scripts/test_king_weapon_loadout_static.sh
```

執行前應使用同一份完整 checkout；不得在正式服務上執行建角／破壞性測試。若腳本因環境缺失無法執行，標示 BLOCKED，不得寫成 PASS。

## 尚缺的獨立證據

1. 真正手機 Safari／其他目標瀏覽器的互動截圖或操作紀錄。
2. 普通玩家跨登出／重登入的背包、武器與技能資料持續性。
3. 非 KING 身分的地圖、NPC、商店、戰鬥及裝備 Journey。
4. Neon／Render 實際跨部署持久化。
5. Work 導入的地圖、NPC、防具等新內容的獨立 Runtime Regression。

原則：Evidence First；Static PASS ≠ Runtime PASS；Render LIVE ≠ Gameplay PASS。
