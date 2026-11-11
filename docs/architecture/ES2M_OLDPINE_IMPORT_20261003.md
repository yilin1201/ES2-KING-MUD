# ES2M 老松林完整區域導入（2026-10-03）

## 證據與範圍

- ES2M 來源：`wolfer168/es2-webmud`。
- 固定來源 HEAD：`e93dad172cb1472dae3eba0a2d1978c12b678985`。
- 來源路徑：`source/upstream/mudlib/d/oldpine/`。
- 本批保存並導入 50 個房間、17 個 NPC、5 個區域物件；另補 3 個 NPC 直接引用的 `custom/armor` 相依檔。
- 原始檔案保持來源內容，不在保存層改寫敘述、數值、NPC 或出口。

## Runtime 接線

- Pinned Original Runtime 原先沒有 `/d/oldpine`，因此本批只在該目錄完全不存在時複製；若未來出現同名區域，腳本立即停止並保留既有內容。
- 雪亭南門原有註解出口指向不存在的 `/d/oldpine/road1`；生成 Runtime 改接 `/d/oldpine/entrance`。
- `entrance.c` 的 `northwest` 原始來源已指回 `/d/snow/sgate`，形成雙向入口。

## 驗證邊界

- `test_es2m_oldpine_topology.py` 驗證檔案數、區域標記、房間出口、一般雙向出口、NPC 引用、三個裝備相依檔與雪亭入口。
- Static／檔案拓樸 PASS 與隔離 Runtime overlay PASS，不代表 Driver 編譯、普通玩家移動、NPC 對話、戰鬥、掉落或任務 Gameplay PASS。
- GitHub Actions 已知基礎設施故障時不以重跑 Actions 取代本地驗證。
