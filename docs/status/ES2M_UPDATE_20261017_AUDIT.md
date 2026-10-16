# ES2M → ES2-KING 來源更新稽核（差異清單已直接寫入）

- 稽核日期（UTC）：2026-10-17
- 上游：`wolfer168/es2-webmud`，`main`
- 比對基準：`6574724aeac69c3f353fad5b2da90ccfab3714b1`
- 已查最新上游 HEAD：`71693beb79ced81d51719ea1ccf7c02c641ca9b0`
- 比對結果：`ahead`；新增提交 `54`；差異路徑 `293`
- 路徑狀態統計：modified=77、added=213、renamed=3
- 差異總計：changes=37706、additions=37520、deletions=186
- 完整逐路徑清單：`docs/status/ES2M_SOURCE_DIFF_MANIFEST_20261017.csv`

## 本次已確認的核心變更範圍
- 戰鬥核心：`source/upstream/mudlib/adm/daemons/combatd.c`、`source/upstream/mudlib/feature/char/combat.c`、`source/upstream/mudlib/feature/char/skill.c`
- 職業／經驗：`source/upstream/mudlib/adm/daemons/chard.c`、`source/upstream/mudlib/cmds/std/conjure.c`、`source/upstream/mudlib/cmds/usr/praise.c`、`source/upstream/mudlib/daemon/class/taoist.c`、`source/upstream/mudlib/daemon/skill/absorption.c`、`source/upstream/mudlib/daemon/skill/archaic_attainment.c`、`source/upstream/mudlib/daemon/skill/literate.c`、`source/upstream/mudlib/daemon/skill/taoism-spells.c`
- 新增戰鬥流程文件：`docs/martial_arts/戰鬥流程說明.md`

## 寫入與 Runtime 邊界
- 本次已把上游逐檔差異清單寫入 ES2-KING 分支，作為可追溯的來源證據。
- 此清單不是完整 mudlib 鏡像，也不代表 293 個路徑已全部匯入 Runtime。
- ES2M 全量鏡像目前仍未生成：`es2m_source_mirror/UPSTREAM_HEAD.txt` 與 `es2m_source_mirror/MANIFEST.json` 尚不存在。
- GitHub Actions run `38944949116` 的 job `117121936072` 為 failure，`steps` 為空且無 artifacts；目前證據指向 runner/job 啟動前阻塞，無法從此資料確定是否為 quota、權限或 GitHub runner 配置。
- 不將上游版本標記為 Annihilator Original ES2；不直接覆蓋 Original ES2 或 KING Expansion。
- PR #13 必須維持 OPEN / NOT MERGED。

## 下一階段移植原則
- 先完成來源鏡像及 SHA-256 驗證，再逐檔比較 ES2M、KING 快照、Original ES2 基線與 KING 自訂差異。
- 對戰鬥核心、職業經驗、學習成長等共用程式採三方合併與針對性測試；新地圖、NPC、書籍與物品依依賴關係批次匯入。
- 未經相容性檢查的來源差異只列為候選，不直接套用至遊戲 Runtime。
