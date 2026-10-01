# ES2M 振武軍營：批次導入與衝突待決（2026-10-02）

來源：`wolfer168/es2-webmud` 固定 tree `10aa4561ab47813becbcb6a48f2a2a188e128d5d`，路徑 `source/upstream/mudlib/custom/zhenwu/`。來源檔註明部分地圖拓樸與 NPC 配置取自使用者圖片，因此**不可擅自宣稱全部為歷史 Original ES2 Canon**。

## 本批已保存
- 17 個房間（big_tent、camp、gate、shed、yard02～yard14）。
- 5 個 NPC（魯熙年、米沛、士兵、練習靶等）。
- 6 個物件（徵兵石、長槍、軍營護甲與武器）。
- 共 28 個來源檔案，以原文保存於 `es2m_snapshot/mudlib/custom/zhenwu/`，由既有 custom Runtime overlay 複製。
- `scripts/test_es2m_zhenwu_topology.py` 驗證房間內部出口、NPC 與物件引用；`scripts/test_king_omega_static.sh` 驗證完整 Runtime 檔案。

## 功能衝突：暫不擅自改動
1. **軍營入口**：ES2M `custom/zhenwu/room/gate.c` 的 east 指向 `/d/snow/sgate`；固定 Original ES2 `/d/snow/sgate.c` 的 west 註解指向 `/d/newcamp/gate`。是否以振武軍營取代／新增該路線，需先核對現有地圖與使用者決策。**本批不修改雪亭出口。**
2. **徵兵規則**：ES2M `custom/zhenwu/obj/recruit_stone.c` 的 enlist 僅接受男性 commoner/fighter，並將其轉為 soldier；這會影響玩家職業流程。完整保存來源，不主張已通過普通玩家的職業轉換測試。

## 驗證界線
來源檔案導入 ≠ 區域已向普通玩家開放。靜態檢查 ≠ Runtime / Gameplay PASS；待 Render 建置與普通玩家流程實測。
