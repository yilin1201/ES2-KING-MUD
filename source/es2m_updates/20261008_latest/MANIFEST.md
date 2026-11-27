# ES2M 最新增量同步 — 2026-10-08

## Source

- Repository: wolfer168/es2-webmud
- Branch: main
- Current HEAD: be98db057a7de64f368037b6bad9504764cdd854
- Previous KING tracked baseline: 5f042999e0d884ab35808a1c48a9e70bea46667f
- Delta: 52 commits
- Purpose: 將 ES2M 最新變更納入 ES2-KING 的 Evidence / Source Update 層。

## 同步策略

本次採 Evidence First（證據優先）與最小必要修改。

### 可直接進入 ES2-KING 更新層

1. 雪亭鎮廣場留言板
   - /daemon/board/snow_board.c
   - /d/snow/square_w.c
   - 所有玩家可讀寫
   - 容量 100 篇
   - 廣場維持 no_fight

2. 李家村小旅店
   - /d/lee/inn.c
   - 明確設定 no_fight

以上內容不覆蓋 KING 核心戰鬥、存檔、權限或其他 Work。

### 已確認但暫不直接覆蓋 KING Runtime 的內容

以下 ES2M 最新內容已完成來源確認，但因目前 ES2-KING 有其他平行 Work、既有 Project Canon 或核心程式保護規則，先保留為 Evidence，待逐檔 Compare 後再整合：

- 新版武功共用引擎 /std/martial_art.c
- /std/martial_art.h
- combatd.c / feature/char/combat.c
- feature/char/skill.c
- feature/equip.c
- feature/npc/vendor.c
- enhanced.c 武器詞綴
- lunmay / advance_lunmay / hainmay_force
- sanmeendo / tiger-force
- std/bboard.c
- std/room/hockshop.c
- web/app.js / web/session_recorder.js
- 其餘 ES2M 測試及文件

原因：不得因 ES2M 新版較新就整檔覆蓋 KING；尤其戰鬥、武功、裝備、Vendor、Save、WebSocket 等均需維持 KING 既有功能與其他 Work 的隔離。

## 最新 ES2M 重要變更

- 隨機武器詞綴機率改為：普通 80%、只有前綴 15%、前綴＋後綴 5%。
- 詞綴名稱改為依前綴／後綴分色。
- 雪亭鎮廣場西側新增「雪亭鎮留言板」，100 篇容量，所有玩家可讀寫。
- 李家村小旅店設定為非戰區。
- 冷梅莊新增／更新：冷梅劍法、傲梅暗劍訣、寒梅心法。
- 招架規則更新，包含 heavy_parry 新規則。
- 新版 martial art engine 與 special_hit 機制。
- Web HUD 背景查詢降低頻率、背景分頁暫停、切回立即更新。
- WebHUD 傳輸分段時避免顯示 @@WEBHUD 殘片。

## Validation

- ES2M HEAD 已確認：be98db057a7de64f368037b6bad9504764cdd854
- 本次同步不宣稱上述核心內容已完成 KING Runtime PASS。
- Runtime 整合必須另行進行 targeted compare / build / runtime journey。
