# ES2M → ES2-KING 更新核對：2026-10-12

## 已確認來源

- ES2M repository：`wolfer168/es2-webmud`
- 本次來源 HEAD：`b05f52591d7df60f90305d88d271b59086117397`
- 前一個 KING 已記錄基準：`a1d4f08bcb4a24dbe9abb8618bd32f8e8f0b2192`
- 兩者差異：15 commits；其中 8 個 mudlib runtime 檔案涉及本次軍人技能改版。
- 已將該提交的 8 個 runtime mudlib 檔案封存至 `source/es2m_updates/20261012_b05f5259/`，並保存來源 blob SHA。

## 本次更新範圍

- `adm/daemons/combatd.c`：格擋成功時給予 `heavy_parry` 經驗。
- `cmds/std/berserk.c`、`daemon/skill/berserk.c`：狂擊亂鬥經驗與升級獎勵。
- `feature/equip.c`、`daemon/skill/powerblow.c`：重擊術經驗與升級獎勵。
- `custom/zhenwu/npc/mee_pei.c`、`custom/zhenwu/obj/recruit_stone.c`、`daemon/skill/heavy_parry.c`：強力格擋改由米沛按軍人等級及戰場功勳傳授。

## Runtime 相容性判定

**狀態：SOURCE SNAPSHOT PASS；RUNTIME INTEGRATION BLOCKED / NOT GAMEPLAY PASS。**

1. KING Dockerfile 固定使用 Original ES2 commit `cc45c06af4852380e5148dad3c9d53ff06854f2c` 作為 Runtime 基底。
2. 已直接核對該 Original 基底的 `mudlib/adm/daemons/combatd.c`：它沒有 ES2M 新版的 `restored_parry_gain()`；因此不能將 ES2M 的 `combatd.c` 整檔覆蓋到 KING Runtime。
3. ES2M 2026-10-11 manifest 已將共享 combat daemon、gain/score/玩家等級流程列為 archive-only pending compatibility review。2026-10-12 的 `heavy_parry` 更新依賴這個尚未整合的 combat gain 路徑。
4. `feature/equip.c` 與 `cmds/std/berserk.c` 雖有可辨識的精確變更，但單獨套用會讓技能系統部分更新、部分缺失，不能宣告整體功能完成。
5. 因此本次先保存最新上游證據；未以整檔複製方式覆蓋 Original，也未將未完整的軍人技能改版標成已套用。

## 下一步必要工作

- 以 Original ES2、ES2M 2026-10-11 快照、KING Runtime 三方比對 combat、skill、gain/level 路徑。
- 確認 `restored_parry_gain()` 的安全接線、`heavy_parry` 的實際觸發時機，以及技能學成門檻與永久升級獎勵。
- 建立隔離測試，驗證軍人徵兵、狂擊亂鬥、重擊術、強力格擋傳授與成功格擋經驗；未通過前不得宣告 Runtime PASS。
- 不覆蓋 KING 自訂武學、種族、戰鬥規則或既有 NPC 行為；PR #13 保持 OPEN / NOT MERGED。

## 證據來源

- ES2M latest commit: https://github.com/wolfer168/es2-webmud/commit/b05f52591d7df60f90305d88d271b59086117397
- Previous KING ES2M delta manifest: `source/es2m_updates/20261011_latest/MANIFEST.md`
- Current evidence snapshot: `source/es2m_updates/20261012_b05f5259/MANIFEST.md`
