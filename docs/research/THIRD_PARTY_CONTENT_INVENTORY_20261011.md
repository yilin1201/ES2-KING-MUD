# Third-party content inventory／第三方內容來源與採用狀態

評估日期：2026-10-11

## 目的與使用規則

本文件登記從 `wolfer168/es2-webmud` 等第三方重建來源發現、且值得與 ES2-KING 比對的種族、區域、家園、NPC、物品與系統內容。

- **Third-party reconstruction**：第三方重建資料；不等於 Annihilator Original ES2。
- **ES2-KING Expansion**：專案擁有者明確決定採用的新設計。
- **Adopted**：已明確決定採用；仍須以測試證明 Runtime 行為。
- **Reference only**：只供考證與比對，沒有自動導入 Runtime。
- **Unverified**：目前缺少足夠原始碼、版本或實機證據。
- 登記在本文件只代表來源可追溯，不代表已完成玩法驗收。

## 1. 種族／Race

| 內容 | 可追溯位置 | 來源狀態 | KING 採用狀態 | 待辦 |
|---|---|---|---|---|
| 刑天 `headless` | `es2m_snapshot/mudlib/daemon/race/headless.c`；wolfer168 `source/upstream/mudlib/daemon/race/headless.c` | Third-party reconstruction；來源註記為自訂 A–H 種族 | **Adopted by owner decision 2026-10-11**：Runtime 採用屬性、精氣神、護甲 +50、攻擊 +30、防禦 +20、裝備限制與 dance 指令；LPC/Runtime 尚待驗證 | 不回寫 Original ES2；執行對應靜態、編譯及 Runtime 測試 |
| 人類 `human` | `es2m_snapshot/mudlib/daemon/race/human.c`；wolfer168 `source/upstream/mudlib/daemon/race/human.c` | Third-party reconstruction；檔頭標示自訂 A–H 種族 | **Adopted by owner decision 2026-10-11**：Runtime 採用 13–18 屬性、精氣神 35、自然護甲 +10、0.01% 化身轉換機制；LPC/Runtime 尚待驗證 | 保留 Original ES2 M5 證據；不得將第三方數值改標原版事實 |
| 化身 `avatar` | `es2m_snapshot/mudlib/daemon/race/avatar.c`；wolfer168 `source/upstream/mudlib/daemon/race/avatar.c` | Third-party reconstruction；檔頭標示自訂 A–H 種族 | **Adopted by owner decision 2026-10-11**：Runtime 採用 15–20 屬性、精氣神 30、自然護甲 +10；LPC/Runtime 尚待驗證 | 與 Original ES2 Avatar 16–18、護甲 +5 的證據分開記錄 |
| 夜叉 `yaksa` | `es2m_snapshot/mudlib/daemon/race/yaksa.c` | Third-party reconstruction／版本待交叉比對 | Reference only，除非另有 KING 決策 | 比對屬性、精氣神、特殊能力及 Original 證據 |
| 阿修羅 `ashura` | `es2m_snapshot/mudlib/daemon/race/ashura.c` | Third-party reconstruction／版本待交叉比對 | Reference only，除非另有 KING 決策 | 比對屬性與創角條件 |
| 黑齒 `blackteeth` | `es2m_snapshot/mudlib/daemon/race/blackteeth.c` | Third-party reconstruction／版本待交叉比對 | Reference only，除非另有 KING 決策 | 比對種族能力、物品及 NPC 依賴 |
| 無腸 `woochan` | `es2m_snapshot/mudlib/daemon/race/woochan.c` | Third-party reconstruction／版本待交叉比對 | Reference only，除非另有 KING 決策 | 比對資源與特殊恢復機制 |
| 焦僥 `jiaojao` | `es2m_snapshot/mudlib/daemon/race/jiaojao.c` | Third-party reconstruction／版本待交叉比對 | Reference only，除非另有 KING 決策 | 比對種族限制與技能相容性 |
| 厭火 `yenhold` | `es2m_snapshot/mudlib/daemon/race/yenhold.c` | Third-party reconstruction／版本待交叉比對 | Reference only，除非另有 KING 決策 | 比對特殊能力與資源消耗 |
| 雨師妾 `rainner` | `es2m_snapshot/mudlib/daemon/race/rainner.c` | Third-party reconstruction／名稱與版本差異需追蹤 | Reference only；KING 正式 Race ID 需依專案規範確認 | 不把 `rainner`／`rainnar` 拼字差異自動視為同一原版設定 |
| 釘靈 `dingling` | `es2m_snapshot/mudlib/daemon/race/dingling.c` | Third-party reconstruction／版本待交叉比對 | Reference only，除非另有 KING 決策 | 查明其是否屬目標 Original 版本 |
| 巫首 `malik` | `es2m_snapshot/mudlib/daemon/race/malik.c` | Third-party reconstruction／版本待交叉比對 | Reference only，除非另有 KING 決策 | 查明其版本年代與 Original 身分 |

### 刑天 `headless`：第三方完整數值快照

來源：`wolfer168/es2-webmud/source/upstream/mudlib/daemon/race/headless.c`。該檔案註記為使用者提供的自訂 A–H 種族資料，不能直接當成 Original ES2 Confirmed。

| 項目 | 第三方重建資料 | 狀態 |
|---|---|---|
| `str` 臂力 | `25 + random(6)`，25–30 | Reference only |
| `cor` 膽識 | `15 + random(6)`，15–20 | Reference only |
| `int` 悟性 | `8 + random(6)`，8–13 | Reference only |
| `spi` 靈性 | `5 + random(6)`，5–10 | Reference only |
| `cps` 定力 | `11 + random(6)`，11–16 | Reference only |
| `dex` 機敏 | `19 + random(6)`，19–24 | Reference only |
| `con` 根骨 | `23 + random(6)`，23–28 | Reference only |
| `wis` 慧根 | `13 + random(6)`，13–18 | Reference only |
| 精／氣／神 | 80／100／30 | Reference only |
| karma | 25 | 歷史版本待交叉驗證 |
| `commoner_score_base` | 160 | 第三方重建 |
| 職業等級上限 | commoner 1、fighter 65、taoist 40、alchemist 40、soldier 60、scholar 50、thief 50、monk -1 | monk -1 的意義待確認 |
| 自然護甲 | +50 | Reference only；KING 未採用 |
| 攻擊／防禦 | +30／+20 | Reference only；KING 未採用 |
| 裝備限制 | 不可穿 `armor`、`cloth`、`head_eq`、`neck_eq` | Reference only；KING 未採用 |

此表保存可追溯的第三方差異。刑天、人類與化身已由使用者明確決定採用於 KING Runtime，但不因此成為 Original ES2 設定。LPC 的 `random(6)` 在常見語義下回傳 0–5，因此表列範圍按起始值至起始值加 5 計算；最終仍應以來源版本的實際執行結果核對。

> 上表是目前可在 Repository 內定位的種族候選清單，不宣稱它們全部都屬於同一個歷史版本，也不把它們推定為 Original ES2 已確認種族。

## 2. 區域、家園與地圖

| 內容／範圍 | 可追溯位置 | 來源狀態 | KING 採用狀態 | 待辦 |
|---|---|---|---|---|
| 老松林 `d/oldpine` | `docs/architecture/ES2M_OLDPINE_IMPORT_20261003.md`；`es2m_snapshot/mudlib/d/oldpine/` | Third-party reconstruction／逐檔差異來源 | 依既有 Expansion overlay 個別採用；不是整區自動覆蓋 | 逐項驗證房間出口、NPC、物品與任務鏈 |
| 雪區 `d/snow` | `es2m_snapshot/mudlib/d/snow/`；`source/es2m_updates/20261011_latest/` | Third-party reconstruction／內容快照 | 只採用已審核的相容性修正 | 維持 KING 凍結武功與自訂成長表 |
| 五堂鎮／武當相關區域 | `es2m_snapshot/mudlib/d/wutang/`；相關 ES2M 匯入紀錄 | Third-party reconstruction／逐檔比對 | 依明確採用紀錄處理 | 驗證地圖連通、NPC、技能傳授及戰鬥流程 |
| 其他家園／出生地 | 來源快照與第三方區域樹 | Third-party reconstruction／未逐項封閉 | Unverified；不整包匯入 | 需逐區建立房間、出口、NPC、物品與任務清單 |

## 3. 系統與武學保護邊界

| 項目 | 來源／保護位置 | 採用政策 |
|---|---|---|
| ES2M 武功與技能 | `source/es2m_updates/`、`es2m_snapshot/` | 來源封存與 Runtime overlay 分離；不直接覆蓋凍結 KING 武學 |
| 瘋虎功 | `es2m_snapshot/mudlib/daemon/skill/tiger-force.c` 與最新來源封存 | 保留使用者定案的 KING 自訂成長表 |
| 冷梅劍法／寒梅心法／傲梅暗劍訣 | `es2m_snapshot/king_frozen_baseline/` | 凍結基準優先；只允許 Blocking Regression 的最小修復 |
| Oracle 部署參考 | `deploy/oracle/` 與部署文件 | 可參考架構，不得複製或洩漏其他主機的秘密與玩家資料 |

## 4. 每項內容的驗收狀態

新增或採用任何第三方內容前，至少記錄：

1. 來源 Repository、分支／Commit、檔案路徑。
2. 內容分類：Third-party reconstruction、Original evidence 或 ES2-KING Expansion。
3. 採用狀態：Reference only、Pending review、Adopted 或 Rejected。
4. Original ES2 證據是否足夠；不足時維持 `Unverified`。
5. 依賴的 daemon、NPC、物品、技能、地圖出口及資料保存方式。
6. 靜態測試、LPC 載入、Runtime 旅程及回歸測試結果。
7. 是否影響已凍結武學、玩家存檔、帳號登入或既有地圖連通。

**禁止事項：** 不得自動套用到 Original ES2；不得因為第三方程式可以編譯，就宣稱內容與原版一致或玩法驗收完成。

## 5. 後續批次

- [ ] 完成 A–H 自訂種族逐檔差異與依賴盤點。
- [ ] 完成家園／出生地的地圖出口與 NPC 清單。
- [ ] 完成老松林與雪區的任務、物品、技能依賴驗證。
- [ ] 對每個已採用的 Expansion 內容連結對應測試與 Runtime 證據。
- [ ] PR #13 保持 OPEN / NOT MERGED。
