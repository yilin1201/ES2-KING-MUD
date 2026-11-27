# 人類與化身／Human & Avatar — ES2-KING Runtime 採用基準

> 狀態：**ES2-KING Runtime 已依專案擁有者指示採用 wolfer168/es2-webmud 的 ES2M 設定**
>
> 分類：Third-party reconstruction adopted by ES2-KING Runtime；不是 Original ES2 已確認設定。
>
> 來源：
> - https://github.com/wolfer168/es2-webmud/blob/main/source/upstream/mudlib/daemon/race/human.c
> - https://github.com/wolfer168/es2-webmud/blob/main/source/upstream/mudlib/daemon/race/avatar.c
>
> Runtime 套用方式：`scripts/apply_race_phase2_runtime.sh` 從 `es2m_snapshot/mudlib/daemon/race/` 複製 `human.c` 與 `avatar.c` 到隔離的遊戲 Runtime。不得將這些第三方設定回寫成 Original ES2 Canon。

## 1. 人類／human（ES2M 採用值）

| 項目 | ES2M 設定 |
|---|---|
| 八大屬性 | `str/cor/int/spi/cps/dex/con/wis = 13 + random(6)`，依 LPC 常見語義為 13–18 |
| 精／氣／神 | `gin/kee/sen = 35/35/35` |
| 自然護甲 | `apply/armor +10` |
| karma | 5 |
| commoner_score_base | 100 |
| 職業等級上限 | commoner 1、fighter 50、taoist 50、alchemist 55、soldier 50、scholar 60、monk 65、thief 50 |
| 體重 | 若未設定，使用 `40000 + (str - 13) * 5000` |
| 年齡 | 若未設定，使用 `14 + random(4)` |
| 特殊規則 | 新建 Human body 初始化時有 `random(10000) == 9999` 的 0.01% 機率改設為 `avatar` |

## 2. 化身／avatar（ES2M 採用值）

| 項目 | ES2M 設定 |
|---|---|
| 八大屬性 | `str/cor/int/spi/cps/dex/con/wis = 15 + random(6)`，依 LPC 常見語義為 15–20 |
| 精／氣／神 | `gin/kee/sen = 30/30/30` |
| 自然護甲 | `apply/armor +10` |
| karma | 5 |
| commoner_score_base | 100 |
| 職業等級上限 | commoner 1、fighter 70、taoist 70、alchemist 70、soldier 70、scholar 70、monk 65、thief 70 |
| 體重 | 若未設定，使用 `40000 + (str - 13) * 5000` |
| 年齡 | 若未設定，使用 `14 + random(4)` |

## 3. 採用與驗收規則

1. 上表是 ES2M 第三方版本的採用基準，不得拿來改寫 `original_es2/` 內已記錄的 Original ES2 M5 證據。
2. Runtime overlay 應以 `es2m_snapshot/mudlib/daemon/race/human.c` 與 `avatar.c` 為來源；修改快照前必須先更新來源差異紀錄。
3. 靜態測試只能證明檔案內容與套用路徑符合契約；仍須以 LPC/Neolith Runtime 創角、存檔、登出、重新登入測試驗收。
4. 若 ES2M 上游版本更新，先比對來源 Commit 與檔案差異，不得未經審查自動覆蓋 KING 自訂內容。
