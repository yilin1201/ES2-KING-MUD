# ES2M 更新核對與 KING 整合紀錄（2026-10-11）

## 來源基準

- 上游：`https://github.com/wolfer168/es2-webmud`
- 上游分支：`main`
- 最新 HEAD：`a1d4f08bcb4a24dbe9abb8618bd32f8e8f0b2192`
- 前次核對 HEAD：`06e8f68f89d8da62507726b60208408ad320c899`
- Compare 結果：13 commits ahead；21 個變更檔案。
- KING 分支：`build/original-es2-races-phase2`
- PR #13：必須維持 OPEN / NOT MERGED。

## 本次已整合至 KING Runtime Overlay

| 檔案 | 同步內容 | 保護規則 |
|---|---|---|
| `daemon/skill/hainmay_force.c` | 武學之道改為 30 級起以 `(lv - 29) * 10` 計算；補回冷梅莊門派與 15 級學習條件；修正內功修習點數公式 | 保留 KING 的寒梅十重、屬性與精氣獎勵、招式與特效 |
| `feature/char/skill.c` | 技能屬性成長機率同步 ES2M 最新八段分級表 | 保留 KING 專屬 `king` 300 級上限條件、其他玩家 200 級上限與既有技能門檻；未把 ES2M 的人物升級流程整檔覆蓋 |
| `std/martial_art.c` | 一般出招與特效攻擊加入武器參數物件型別防護 | 保留 KING 武功引擎與每級獎勵 |
| `d/snow/npc/obj/pot.c` | 水喝完後重新建立並補滿 | 以 Runtime Overlay 局部覆蓋，不改 Original ES2 原始保存 |
| `d/snow/npc/obj/wine_pot.c` | 酒喝完後重新建立並補滿 | 以 Runtime Overlay 局部覆蓋，不改 Original ES2 原始保存 |

## 已更新 ES2M 來源快照

`es2m_snapshot/mudlib/` 已將上游本次修改的 12 個 mudlib 檔案同步至 HEAD `a1d4f08`，包括 combatd、gain、score、井、水缸、酒缸、寒梅心法、瘋虎功、人物 score/skill、martial_art 與 room。新增的 gain／score／room 檔案只作來源快照，不自動成為 Runtime Overlay。

完整 21 個變更檔案（含設計文件、測試與 Web UI）已保存於 `source/es2m_updates/20261011_latest/`，另保留前次新增的 `custom/wizroom/w/windstory/room/home.c`。

## 暫不直接移植的內容

以下更新已保留在 ES2M 快照與來源封存，但不直接覆蓋 KING Runtime：

1. `adm/daemons/combatd.c`：戰鬥核心高影響變更，必須先對照 KING 的 NPC 強度、閃避／招架、戰鬥經驗及 Original ES2 相容性。
2. `cmds/usr/gain.c`、`feature/char/score.c`、`cmds/usr/score.c`：ES2M 引入 gain 時技能／人物升級與狀態顯示契約；KING 有獨立技能成長及 300 級授權規則，尚不能整檔覆蓋。特別是 `try_level_up()`／`apply_gain_progression()` 不可在沒有相容實作與回歸測試前直接啟用。
3. `std/room.c`：共用房間基礎類別，先保存，避免影響全世界地圖。
4. `d/lee/obj/well.c`：來源註明為 ES2M 新增的李家村水井；尚未確認 KING 地圖出口與房間配置，暫不部署。
5. `daemon/skill/tiger-force.c`：保留上游版本於快照；KING 瘋虎功有使用者指定的成長表，不以整檔覆蓋。
6. Web UI 與 ES2M 自身測試：只保存為外部來源證據，不混入 KING 遊戲 Runtime。

## 驗證狀態

- 上游 HEAD／差異核對：**PASS**（13 commits／21 files）。
- 原始來源與測試／文件／Web 檔案封存：已建立。
- Runtime 靜態契約測試：已更新 `scripts/test_es2m_latest_martial_updates.py`，待 GitHub Actions 實際執行。
- LPC 編譯、Neolith 實機與玩家端到端測試：尚未執行，不宣稱 PASS。
- Original ES2 原始保存：未修改。
- PR #13：不合併。

## 後續優先項目

1. 等待 GitHub Actions 回報本次靜態閘門結果。
2. 若靜態測試通過，再針對 gain／人物升級機制做獨立相容性設計與測試；不可直接套用 ES2M 的整套角色升級程式。
3. 對 combatd 進行逐段差異審查，確認可安全移植的最小變更後再另行整合。
