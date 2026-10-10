# ES2M 最新更新核對與 KING 補充紀錄（2026-10-11）

## 來源與基準

- 正式來源：`wolfer168/es2-webmud`（ES2M）
- 目前 ES2M `main` HEAD：`06e8f68f89d8da62507726b60208408ad320c899`
- 前次 KING 同步稽核基準：`60c12efac447d63730f953ac83ef47fdc62f7368`
- GitHub Compare：前進 1 個 commit，新增 1 個檔案，沒有其他程式差異。
- KING 目標分支：`build/original-es2-races-phase2`
- PR #13：保持 OPEN / NOT MERGED。

## 本次新增的 ES2M 內容

| 分類 | 上游檔案 | 來源證據 | KING 處理 |
|---|---|---|---|
| Wizard room／房間內容 | `source/upstream/mudlib/custom/wizroom/w/windstory/room/home.c` | blob `a6f21e4d4763d1adf39c7c75bc9597608f963fc8` | 已存入獨立 ES2M 更新證據封存；不加入可執行 Runtime Overlay |

該房間描述為「未知地方」，東側連往同目錄的 `dragon_inn`，西側連往 `/d/snow/square_w`，並建立關閉的東側門。這是自訂 wizard-room 路徑，尚未確認其房間依賴完整性、是否屬於正式玩家區域或是否為測試內容。因此只保存來源與路徑，不直接啟用於 KING 遊戲。

## 已核對的既有 ES2M 更新

下列內容在前次同步範圍內，已存在 KING Runtime，沒有重複覆蓋：

- `daemon/skill/mayin.c`（梅影身法）：KING 與 ES2M 同一 blob。
- `daemon/skill/seven.c`（七巧如意手）：KING 與 ES2M 同一 blob。
- `std/martial_art.c`（新版武功共用引擎／學成當級獎勵）：KING 與 ES2M 同一 blob。
- `d/wutang/crossroad.c`（五堂鎮交叉路口生成點）：KING 與 ES2M 同一 blob。
- `d/wutang/npc/may_yin_fong.c`（梅影風）：KING 保留必要相容差異，不整檔覆蓋上游版本。差異包含正式種族代碼 `rainnar`（ES2M 使用 `rainner`），以及依技能實際入門等級／點數門檻傳授的修正。

以上來源路徑與內容已對照當前 ES2M `main`。既有同步紀錄指出，梅影風完整拜師、五項武學實戰與 NPC 強度平衡仍不可僅憑靜態比對宣稱全部 Gameplay PASS。

## 本次驗證與結論

- **ES2M HEAD／差異核對：PASS**（`60c12ef` → `06e8f68`，1 commit／1 file）。
- **來源封存：已新增**，保留上游路徑及來源 blob 證據。
- **Runtime 變更：無**。本次唯一新增檔案尚未證明適合玩家區域，故不把它部署到遊戲。
- **Runtime 測試：未執行**，因沒有變更可執行程式；不可把來源封存說成 Runtime PASS。
- Original ES2 保存來源不變；不 Merge PR #13、不部署。

## 檔案索引

- 本紀錄：`docs/research/ES2M_UPDATE_SYNC_20261011.md`
- 來源封存清單：`source/es2m_updates/20261011_latest/MANIFEST.md`
- 原始來源封存：`source/es2m_updates/20261011_latest/source/upstream/mudlib/custom/wizroom/w/windstory/room/home.c`
- 前次完整盤點：`docs/ES2M_UPDATE_AUDIT_20261010.md`
- 前次同步閘門紀錄：`docs/research/ES2M_UPDATE_SYNC_20261010.md`
