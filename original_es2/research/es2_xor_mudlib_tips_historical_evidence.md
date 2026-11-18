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
## 11. ES2 Tips / Google Sites Depth Recovery Ledger — Round 1

使用者指定從 https://es2tips.blogspot.com/?m=0 逐篇、逐連結、逐層追蹤至 DEPTH EXHAUSTED。本節記錄本輪實際已讀與待追節點；不是宣稱全站已完成。

### 11.1 Blogger Archive 範圍
從 2014/10 頁面的 Blogger Archive 取得月份計數：2019/10(1)、2015/11(8)、2014/11(20)、2014/10(12)、2014/09(9)、2014/08(24)、2014/07(2)、2014/04(1)、2014/03(61)、2014/02(24)、2014/01(22)、2013/08(7)、2013/07(3)、2013/06(36)、2013/05(110)、2012/02(1)。總量約 341 篇（依 archive count）。
已直接打開月份頁：2012/02、2013/05、2013/06、2013/07、2013/08、2014/01、02、03、04、07、08、09、10、11、2015/11、2019/10。

### 11.2 Pot-w Official Board Historical Snapshot
2014/01 Blog 保存 2014-01-26 直接連 es2.muds.net 後的 pot-w read 記錄，屬 Archived Gameplay / preserved official board output。
重要公告節點：
- 2009-08-08 白象寺新門派 bonze.wele。
- 2009-11-16 race update。
- 2010-04：18 銅人巷/18 銅人正式開放。
- 2010-04-25 鬼首任務，起點任蕭蕭。
- 2010-04-25 新任務從給葉翔 drinkblood 開始；最終獎勵 con+1、dex+1、單手 sword；補隱教/郎夷故事。
- 2010-04-25 雍家任務，風嘯 90 觸發。
- 書生、方士、盜賊、道士等多次技能/職業更新。
- pot-w 後期有新手指引任務 NPC。
Evidence：STRONG Archived Gameplay；公告文字可支持歷史功能存在與時間線，但仍須目標版本 Source/Runtime cross-check。

### 11.3 Strong Gameplay Quest Chains
2014/01 肖麗穎鏈：霹靂雷火彈 → 肖麗穎 → 山腰 dig 寶貝（需鋤頭）→ 追風劍 → 梅嵐武 → 楊子陵 → 河邊煙波釣叟 → 青絲釣竿；保留 say/give/dig/swim/crash、Room exits、NPC、物品 id/屬性。
2014/01 古刃旋芒鏈：宋安江 → 周大發 → 豬心 → 鯉君渡村長 → 濁魚珠 → 炭燒乳羊腿 → 宋安江 → 旋芒碎片 → attach/recovery context。
2014/08 解仇/胡惑鏈：哭無望 → 柳生木丸 → 劉乙手書 → 魚鐵山 → 玄蘇劍 → 毒刀胡惑 → 劉乙忘玄 → 梅影風 → 血石分支；分支一解除封山/雪吟/虎刀仇恨，分支二幫會木箱 + 100 殺業。
2014/08 虎刀護衛進階：高慎推薦 → 韓笑 → 鐵虎牙 → 軒轅龍骨刀後續。

### 11.4 Scholar Runtime / Class Historical Evidence
2014/08 實際 scholar.myst 角色紀錄保存：myst-sword、myst-steps、myst-force、literate、archaic attainment、mysticism、vacancy ax；可視為 Archived Character Runtime Evidence。
Google Sites 書生頁：步玄派與玄天教兩系；兩派可再走生存型進階，亦可為朝廷諜報機構效力。
Google Sites 門派簡介：步玄可雙劍、小步玄劍、步玄七絕、奇門劍訣、乾坤三轉；玄天有玄天劍訣、藏雲訣等。此頁含玩家評述，精確倍率/評價不直接升級 Canon。

### 11.5 Google Sites Deep Graph
由 Blog FAQ backup 內原始 URL 追入 https://sites.google.com/site/es2mud/home 。首頁自述為 ES2 天朝帝國協作平台，用於整理故事、世界觀與遊戲內容設定。
已訪問主要樹：主線任務、主題故事、遊戲截字、玩家原創、新手任務 1/2、2/2。
遊戲截字 sitemap 暴露：歷史故事、神話設定、11 種族、國家/天朝地圖、五堂/雪亭、七職業、裝備、煉丹、天靈地靈、Q&A、四場掌門對戰等。

### 11.6 Main Story / Lore
主線任務頁確認七職業：武者、道士、和尚、書生、小偷、軍人、方士；人物只能加入一職業/一門派/一分支。
十三靈任務是侮天鬼主線的一部分，並與技能天賦 reset 關聯。
主線疑團包括：大邪道人/殘蟻、魚鐵山/劉乙忘玄、武林盟主、白象寺、封鬼慘案、梅影風夫人、朝廷與侮天鬼、虎刀門二師父、阿寶。
神話頁保存寒於氏、侮天鬼、穿靈、旋芒、十三靈及人界/混沌界/陰間設定。

### 11.7 Race Pages — Direct Read
已逐頁讀：人類/人類族、刑天、厭火、夜叉、巫首、無腸、焦僥、釘靈、阿修羅、雨師妾、黑齒。
各頁保存業力、適合職業/等級、初始精氣神、八屬性上限、被動、主動能力。
重要 Conflict：Google Sites 黑齒頁明寫需要業力 3；專案既有黑齒 3/5 conflict 保持，不覆寫。
人類頁同時保存低機率成為「人類族」與人類族獨立狀態/能力資料，可作 human-family lineage evidence。

### 11.8 World / Map / Puzzle
雪亭鎮頁的謎題清單包括：阿寶、瞎眼老太婆、貨棧搬箱子、驛站送信、振武軍營、破舊大宅、黑衣老人女兒。
其中「貨棧搬箱子算不算苦力？」獨立支持 Phase 3 貨棧工錢內容歷史存在；不取代 Repo Runtime PASS。
五堂鎮頁列：飲血、巫山雕像、郭布收徒、鎮天神廟、欽差、渡船等 puzzle hooks。

### 11.9 Reset / 十三靈 Quest Graph
Google Sites Q&A 保存：動物 war → 雷神/風神 → 天龍島火神/天龍 → 四神印記 → 四鬼遺物（赤魈 necklace、青蛛 girdle、濁魚 ring、旱魃 hairpin）→ 卯天樹四鬼封印 → 星光 ring → insert 4 seal → 一次 reset skill 權力。
蜈蚣 war：穿靈 → 京畿地下砍聖木 → 聖木殘根/破碎印記。
天靈：三把神武器 → 赤魈村許願池 → 天命刃 + eye。
地靈：聖木殘根 → 京畿神社 donate → 後續 chain → 悍地斧 + heart。
日月神祇：京畿神社 donate heart/eye/ring 開始。
另有天靈地靈專頁，明確警告召喚方法曾被 Zorg 修改，故該攻略必須標 VERSION-SENSITIVE。

### 11.10 2012 Quest Start Registry
Q&A 的 2012-11-20 新任務清單：
- 安懶的毛筆：康平村阿桂。
- 金絲翡翠帶：京畿小酒館玄天教法王武天。
- 古刃旋芒：史部尚書府漕幫禮堂分舵主宋安江。
- 冥王寶戒：尚書府劉二爺。
- 青絲釣竿/追風劍：雪山妖妃肖麗穎。
- 黃玉佩：京畿渡口戒言大師。
- 混元一氣袋：百里香客棧老酒鬼。
- 解仇任務：雪吟莊東廂房哭笑門左使哭無望。
- 六靈玄衣：京畿神社李再延。

### 11.11 Q&A System Evidence
Q&A 保存 study book / 私塾 sit、help books、七職業升級精氣神公式、業力計算說明、praise/聲望、死亡→鬼魂→register→地府→復活、結仇、combat 指標語意、peek 暗格、股票/人口職業資訊、天賦算命、桐城/漕幫 Quest 起點等。
這些多屬 Player/Archived Documentation；公式需和 Original Source 比對後才可升級。

### 11.12 Embedded Video Nodes
Google Sites 可達但本輪內容抓取受平台節流：
- 新手任務 1/2 YouTube ID: Cm3K7_aKA3w
- 新手任務 2/2: XAMYsot_q5w
- 柳東蘆 vs 景愈濤: XYTHyz1zUHs
- 梅影風 vs 劉乙忘玄: YoWGWTD-qP4
- 梅影風 vs 柳東蘆: YoOFyeZhkIA
- 韓笑 vs 劉乙忘玄: 9ZkzxygP8xQ
狀態：REACHABLE EMBED / CONTENT PENDING；不得標已讀或失效。

### 11.13 Dead-End / Partial Nodes
國家地圖、武貞、智賢、祐聖、部分裝備表與部分歷史頁目前主要只暴露 image/embed；文字 Evidence 不完整。保留節點，後續可用 image/video recovery。

### 11.14 Pending — 必須繼續
1. Blogger 約 341 篇逐篇索引完成度核對，尤其 2013/05、2014/03 大月份。
2. Google Sites 七職業逐頁：武者/小偷/軍人/書生/道士/和尚/方士。
3. 11 種族頁已讀，補圖片/來源衝突 cross-check。
4. World：世界/天朝/五堂/雪亭及其可達下一層。
5. 玩家原創：裝備表、Yew 煉丹、Q&A、天靈地靈、各門派。
6. 六個 YouTube 歷史 Runtime 影片內容 recovery。
7. Blog 每篇內 sites.google / es2.xor / 其他 ES2 link 遞迴追蹤。
8. 建 Visited/Pending/Dead-End 去重表，直到沒有新可達 ES2 節點才宣告 DEPTH EXHAUSTED。

本輪狀態：IN PROGRESS — NOT DEPTH EXHAUSTED。