# ES2 XOR MUDLIB + ES2 Tips Historical Evidence Recovery

> 建檔日期：2026-09-27
> 用途：Original ES2 Phase 3+ 外部歷史證據持續回收。
> 原則：Evidence First；外部資料不因可讀取就自動升格為目前目標版本 Canon。與目標 GitHub Source 衝突時並列保存，不倒灌 Runtime。

## 1. 來源

### X-ES2XOR — ES2 MUD LIB 瀏覽展示
- URL: https://es2.xor.tw/
- 可見根目錄：MANIFEST、adm、cmds、d、daemon、data、doc、feature、include、legacy-ES2、obj、std、wiki。
- 類型：公開歷史 MUDLIB Source/Doc 展示。
- Evidence 等級：STRONG historical source / lineage reference；是否與 ES2-KING 目標正式站版本完全一致，仍須逐檔比對。
- 使用方式：優先作 Source-to-Source cross-check，不直接覆寫目標 Original Source。

### X-ES2TIPS — 天朝帝國裝備實錄 ES2 MUD Tips
- URL: https://es2tips.blogspot.com/
- 已確認文章包含歷史玩家實機紀錄、職業師父位置、公告欄 pot-w 保存、NPC/Quest/Equipment/Map 操作紀錄。
- 類型：Archived Gameplay / Player Record / preserved board output。
- Evidence 等級：PARTIAL～STRONG（依文章是否保存實際 terminal/board output 分級）。

## 2. /d/snow Source Tree 新證據

https://es2.xor.tw/MANIFEST 明確列出 mudlib/d/snow/ 大量 Source。已確認至少包含：

### NPC
alchemist, child, child1-4, foreman, gammer, garrison, girl, guard, herbalist, innkeeper, junkman, lieutenant, miller, oldman, patrol, smith, teacher, waiter, woman, yu。

### NPC Objects
arrow, blue_cloth, blue_jacket, broadsword, cane, clothboot, coin, comb, crate, fur_hat, hairpin, helmet, hoe, invitation, leather_armor, note, pot, roast_chicken, shovel, silversword, slasher_sword, smock, syndicator, tummy_cover, wagon, white_dress, wine_pot, woodblade, woodsword。

### Area / Rooms / Study
bazar, court, inn_hall, post_office, river/riverbank, ruin1/ruin2, school, smithy, square/street/gate 系列、store、tree；skill/dragon_force.c；obj/basic_book.c；obj/literate_book.c。

basic_book.c 為實際 LPC Source，物件為「〖幼學輯要〗」，inherit ITEM + F_STUDY；required skill 為 literate 1，content literate 10。這是 Snow 私塾/讀書系統可交叉比對的 Source Evidence。

## 3. Snowkeep 邊界
目前公開 MUDLIB 的 /d/snow Source Tree 很完整，但本輪仍未找到可決定性證明 /d/snowkeep/entrance 完整區域內容的公開 Source。
- Snowkeep missing content：UNKNOWN。
- 目標 Runtime：BROKEN / UNREACHABLE。
- 不因 /d/snow 可取得就推導 /d/snowkeep；不建立空 entrance，不自行補 NPC/Quest/Reward。

## 4. Scholar / 書生證據
/legacy-ES2/class-all 明確把「步玄派(scholar)」列為職業/門派，師父陸雲舟、地點曼雩台、能力類型劍法/步法。
這證明歷史 ES2 中 scholar 是正式 class lineage 的一部分；但與目標 Phase 3 已驗證的 Snow 私塾 commoner -> scholar entry 之間的版本/進階關係，仍須 Source 比對，不直接合併。

ES2 Tips 2014 職業師父文章保存 fighter subclasses：fighter.fonxan 封山派→柳東蘆；fighter.snow 雪吟莊→魚鐵山；fighter.lunmay 冷梅莊→梅影風；fighter.tiger 虎刀門→高慎；fighter.huge 哭笑門→劉乙忘玄。用途為 identity/location cross-check，不單獨生成 NPC path、HP、skill level。

## 5. Legacy Class / Skill Evidence
/legacy-ES2/class-all 保存天邪派(fighter)、茅山派(taoist)、封山派(fonxan)、山煙寺(bonze)、晚月莊(dancer)、花紫會(bagger)、天生門(blademan)、步玄派(scholar)、慈德派(healer)、天鷹門(tenyin)、烈焰門(spearman)、侮天教(demogorgon)、五毒門(poison)、獨孤派(dugu)。這是 Legacy ES2 分類，不直接等同目前 ES2-KING 七大職業/門派 Canon。

/legacy-ES2/門派師父技能 保存技能 ID/等級型歷史紀錄；封山可見 chaos-steps、fonxanforce、fonxansword、liuh-ken，以及 literate/force/parry/sword/unarmed 關係。技能名稱/lineage 可 cross-check；數值不可未經同版本確認直接 Restoration。

## 6. MUDLIB Doc Evidence
/doc/wiz/all 明確列出 survive、quest、quest2、health、skill、race、commoner、fighter、soldier、thief、(scholar)、combat、weapon、armor、martial、world/story/myth，以及 chaos-steps、fonxansword、liuh-ken 等技能背景。
/doc/build/room 保存 exits、objects、NPC 放置方式，範例直接使用 /d/snow/inn_hall；可理解 Original Room graph，不作內容補造。
/cmds/std/perform.c 保存 perform 指令行為與 snowblade 範例；只作 Original martial command semantics Evidence。目前武功演出維持凍結。

## 7. Quest / Runtime Evidence Gate
ES2 Tips 與 legacy-ES2 可提供 Quest 名稱/故事存在性、NPC identity、地點/路徑、玩家實際命令、Board 公告與 Reward 描述；但 RUNTIME PASS 仍須目標 Runtime 證明 Entry → Progress → Completion → Reward/State → Save。Source Exists / Blog Exists 均不等於 COMPLETE。

## 8. Phase 3 既有 UNKNOWN 不覆寫
- /d/snowkeep 完整 missing area：UNKNOWN / EVIDENCE EXHAUSTED。
- try/fon 缺失 state transitions：UNKNOWN completion。
- __ID_CHALLIE__ object source/path/acquisition：UNKNOWN。
- 貨棧工錢：目標 Repo 已 RUNTIME PASS；外部資料只作 cross-check。
- Scholar Snow 私塾 entry：目標 Repo 已 RUNTIME PASS / BOUNDED；外部步玄派屬 lineage evidence，不倒灌。

## 9. 後續 Recovery Queue
1. 對 es2.xor.tw/d/snow 逐檔建立 Room → NPC → Object → Trigger graph。
2. 搜尋公開 Source 中所有 try/fon state value 與寫入/讀取點。
3. 搜尋 __ID_CHALLIE__、趙丰血書、破布等 identity 關聯。
4. 深挖 legacy-ES2/quest-legacy，拆 Story/Area Quest 與 Random Task Quest。
5. 建立 Scholar legacy lineage：commoner entry → scholar → scholar school/master/skill（若 Source 可證）。
6. ES2 Tips 全站按 Board / Quest / NPC / Map / Equipment / Class 建索引。

## 10. Restoration Gate
只有 CONFIRMED / STRONG 且版本相容 Evidence 可直接支援 Restoration。PARTIAL / RELATED / UNVERIFIED 只能建檔、建 candidate、交叉比對、指引下一步 Recovery。證據耗盡仍保持 UNKNOWN。

Evidence First.
preserve → understand → rebuild → expand.