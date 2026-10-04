# ES2M 2026-10-04 更新證據暫存（非 Runtime 導入）

- 來源：wolfer168/es2-webmud@e93dad172cb1472dae3eba0a2d1978c12b678985（GitHub 已讀取的最新 main HEAD）
- KING 審核基準：45d8d51912236d2492e6169674e719cde2ca7ec3
- 保存方式：原始內容獨立存於 `source/es2m_updates/20261004/mudlib/`；不覆蓋既有 `es2m_snapshot`、Original 或 KING Runtime。
- 原因：新增附加屬性 daemon 依賴及 12 件武器存在連動變更，必須依存檔、實際裝備與既有 KING 功能驗證後才能正式 overlay。
- 已存在且同 SHA 的 `custom/weapon/whip/bamboo_fishing_rod.c` 不重複儲存。
- `daemon/skill/taoism-spells.c` 差異仍屬使用者決策 UNKNOWN，禁止覆蓋。
- 本批屬 SOURCE PRESERVATION / STATIC EVIDENCE，並非 Runtime / Gameplay PASS。

| ES2M 檔案 | 來源 blob SHA | 待確認事項 |
|---|---|---|
| `adm/daemons/enhanced.c` | `cdbecfcc2464046efb1a813148aae21009713d3c` | 附加屬性 daemon 原始依賴、前後綴保存及裝備流程 |
| `obj/area/obj/bastardsword.c` | `d12cba9d7ff76ddd1d89f385dda83f4fbe58b847` | 武器 clonep 隨機詞綴與既有裝備、存檔相容性 |
| `obj/area/obj/blade.c` | `b0f93def2ccbd8b6e1b0d1b262bd79c1ca0201ee` | 武器 clonep 隨機詞綴與既有裝備、存檔相容性 |
| `obj/area/obj/broadaxe.c` | `427dd9bd85a30eb08448b821e6f9d0ccd658adaa` | 武器 clonep 隨機詞綴與既有裝備、存檔相容性 |
| `obj/area/obj/broadsword.c` | `96ec86a37fe721bb2becb31b94c642e82823bf40` | 武器 clonep 隨機詞綴與既有裝備、存檔相容性 |
| `obj/area/obj/curved_blade.c` | `5586650b19794bd859f10af0bf7d4dc472d0bbc2` | 武器 clonep 隨機詞綴與既有裝備、存檔相容性 |
| `obj/area/obj/glaive.c` | `9a0c134489fd32c3049e4c1a6844f3d940852559` | 武器 clonep 隨機詞綴與既有裝備、存檔相容性 |
| `obj/area/obj/greatsword.c` | `a6b92055d60d7ce0a7e123e4776b120eafe710c9` | 武器 clonep 隨機詞綴與既有裝備、存檔相容性 |
| `obj/area/obj/longsword.c` | `2b823f8fb99ff1606e497fbeb4f74345f6a3ce13` | 武器 clonep 隨機詞綴與既有裝備、存檔相容性 |
| `obj/area/obj/pike.c` | `cf8bb5ec73e8b8af5b4caa84dcf384e2dbb039bd` | 武器 clonep 隨機詞綴與既有裝備、存檔相容性 |
| `obj/area/obj/rod.c` | `cf713c245594f46a921ebc7c962e8abaffd792ae` | 武器 clonep 隨機詞綴與既有裝備、存檔相容性 |
| `obj/area/obj/shortsword.c` | `f0d2c4a95b7dd75a296226c04d0b519b3ecbb72e` | 武器 clonep 隨機詞綴與既有裝備、存檔相容性 |
| `obj/area/obj/weirblade.c` | `2fea001993b1e95785b688e03474ff2cc93ffd99` | 武器 clonep 隨機詞綴與既有裝備、存檔相容性 |

後續：使用隔離環境檢查 daemon 編譯、前後綴與裝備存檔行為；不以靜態存在宣稱實際可玩。

## 獨立審查：儲物箱相容性阻礙（V9）

- KING 既存 `es2m_snapshot/mudlib/custom/home/obj/storage_chest.c` blob：`1a9c445394cbf4498f1467b9aec4468bf7547003`；儲物箱未保存或還原 `affix`。
- 鎖定 ES2M `e93dad172cb1472dae3eba0a2d1978c12b678985` 的新版本 blob：`2a6fcab2584841f38571d7b6462b025a7c43ff7b`，已原樣保存至 `source/es2m_updates/20261004/mudlib/custom/home/obj/storage_chest.c`。
- 更新版本在 `pack_object` 保存空或非空 `affix`，`do_retrieve` 透過 `ENHANCE_D->apply_affix` 套用；依賴同批 `enhanced.c`。
- 新增 `scripts/test_es2m_affix_chest_source.mjs` 驗證來源 SHA 與關鍵呼叫。**不可單獨升級 12 件武器的 Runtime overlay**；須連同 daemon 和儲物箱驗證後再導入。
- 本節是導入前審查紀錄；下方 Runtime 結果完成後才解除此 BLOCKED，不回寫或改稱當時已經 PASS。

## V9 增量追蹤（ES2M `087c1736b50a1352b56fd66b3f5d34861dd99228`）

- `e93dad17…` 至 `087c1736…` 共 10 個 Commit、GitHub 比對列出 17 個變更檔。
- 本輪只保存遊戲內容與其正式規格／測試相依，共 12 檔，位置為
  `source/es2m_updates/20261004_087c1736/`；部署腳本、Catalog 與 Web Server
  安全設定不屬 Mudlib 導入範圍，未複製進 Runtime。
- Runtime 安全整合共 19 檔：`enhanced.c`、私人儲物箱及 17 件可產生詞綴的武器。
  覆蓋器在任何寫入前核對來源 SHA 與既有 Runtime SHA；未知同路徑內容會整批停止。
- `d/oldpine/cave_deep.c` 文字修訂與 `d/wutang/npc/guard.c` 新增刀法／單刀已保存，
  但會改變既有完整區域的逐檔一致性閘門，本批不直接覆蓋，狀態維持「已保存／待區域回歸決策」。
- 武器詞綴正式規則未改寫：普通 60%、前綴 30%、前綴＋後綴 10%；
  `taoism-spells.c` 未修改，仍維持 UNKNOWN。
- 隔離 Runtime 驗證必須另外執行；本節的來源保存與 SHA 檢查本身不代表 Gameplay PASS。

## V9 Work 隔離 Runtime 結果

- `ES2M_WEAPON_AFFIX_RUNTIME_E2E_PASS`：普通玩家載入 17 件武器，確定套用「黑鋼火炎」後核對
  攻擊 +10、傷害 +15、膂力 +3、價值 1125，並完成匕首裝備／卸下。
- 私人儲物箱已使用真正 `do_store()`／`do_retrieve()`，完成 save → quit → relogin → retrieve；
  詞綴與能力保持一致，狀態為隔離 Runtime／Gameplay PASS。
- 初次測試誤用防具 `remove` 指令，修正為武器 `unwield`；其後又發現新手無法揮動長劍，
  改用符合普通玩家能力的匕首後通過。這兩項均為測試情境缺陷，未篡改武器重量或玩家屬性。
- 正式 Render、正式 Neon 與公開玩家資料均未使用，因此 Public Runtime／正式 Gameplay 仍未驗證。
