# ES2M 上游更新核對紀錄（2026-10-12）

## 核對結果

- 上游來源：`https://github.com/wolfer168/es2-webmud`
- 上游分支：`main`
- 前次 KING 核對基準：`a1d4f08bcb4a24dbe9abb8618bd32f8e8f0b2192`
- 本次上游 HEAD：`c74f136d78acfb67562bd9b71416c597ffc24521`
- Compare：新增 6 commits，差異 8 個檔案。
- KING 目標分支：`build/original-es2-races-phase2`
- PR #13 必須維持 OPEN / NOT MERGED。

## 本次上游差異分類

| 類別 | 變更檔案 | KING 採用決策 |
|---|---|---|
| WebMUD 前端 | `web/app.js`、`web/automation.js`、`web/chat_window.js`、`web/index.html`、`web/styles.css` | 不屬於 KING LPC 遊戲 Runtime；不匯入 |
| WebMUD 測試 | `tests/test_v32052_chat_capture.py`、`tests/test_v32068_interaction_hud_serialization.py`、`tests/test_v32076_final_skill_and_remove_interaction.py` | 僅驗證上游 WebMUD 行為；不直接匯入 KING |

本次上游新增內容主要是網頁自動化／計時器與可移動的獨立聊天視窗。Compare 清單未出現 `source/upstream/mudlib/**` 或其他 mudlib 遊戲內容檔案。

## 結論

1. **本次沒有發現新的 ES2M mudlib 遊戲資料需要匯入 KING Runtime。**
2. 上游確實有新提交，但變更集中於 WebMUD 前端及其測試；為避免把前端功能混入 LPC 遊戲，不進行 Runtime 程式碼覆蓋。
3. 既有 ES2M 更新快照與 KING Expansion Overlay 維持原狀；Original ES2 原始保存不修改。
4. ES2-KDS 分支近期的 ADMIN GM／Soldier skill 相關提交屬另一個儲存庫的開發內容。除非逐檔比對並確認其與 ES2M 上游來源及 KING Runtime 相容，不將它們直接標記為「ES2M 新增資料」或整檔覆蓋 KING。
5. Oracle 部署是下一階段；本紀錄本身不代表已部署或已更新 Oracle 主機。

## 證據

- 上游 HEAD：`https://github.com/wolfer168/es2-webmud/commit/c74f136d78acfb67562bd9b71416c597ffc24521`
- Compare：`https://github.com/wolfer168/es2-webmud/compare/a1d4f08bcb4a24dbe9abb8618bd32f8e8f0b2192...main`
- 前次核對紀錄：`docs/research/ES2M_UPDATE_SYNC_20261011.md`
