# ES2M → KING 第一批可追溯導入（2026-10-02）

## 原始來源與版本
- ES2M：`wolfer168/es2-webmud`，已檢查來源 tree `10aa4561ab47813becbcb6a48f2a2a188e128d5d`。
- 來源目錄：`source/upstream/mudlib/`。
- KING 既有基底仍為另一來源 `taedlar/es2_mudlib` 的固定版本，兩者**不能**當作同一份原始碼。
- 本批僅補入 KING 原本缺少的 ES2M 參考裝備，原始碼保持與上述來源相同；既有 `scripts/apply_race_phase2_runtime.sh` 會複製 `es2m_snapshot/mudlib/custom/` 至 Runtime。

## 本批檔案
| 來源相對路徑 | 名稱 | 價值 | 已知設定 |
|---|---|---:|---|
| `custom/armor/armor/battle_armor.c` | 步軍戰鎧 | 26000 | armor 40；wittiness 25 |
| `custom/armor/armor/ring_mail.c` | 鎖子鎧 | 8000 | armor 5 |
| `custom/armor/cloth/cyan_cloth.c` | 青布官服 | 17000 | armor 3；int 1；mysticism 5 |

這些檔案屬 ES2M 的「參考裝備」資料。**只表示程式資產可載入，不代表已取得 NPC 掉落、商店來源或玩家取得路徑的原始證據。** 不以 KING 專屬權限替普通玩家驗證。靜態測試新增 Runtime 檔案存在檢查，Runtime 行為須待 Render 建置與普通玩家測試。

## 後續衝突決策
若同一路徑在 ES2M、固定原始基底或 KING 擴充中有不同功能，不自動覆寫。提供路徑、差異及可能影響後，交 Owner 決定。
