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
- 目前不具 LPC 隔離 Runtime／普通玩家實測證據；詞綴跨登入與儲物箱功能仍為 **BLOCKED**，不是 PASS。
