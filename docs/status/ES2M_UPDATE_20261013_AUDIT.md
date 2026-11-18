# ES2M → ES2-KING 更新核對：2026-10-13

## 來源與差異

- ES2M 主來源：`wolfer168/es2-webmud`, branch `main`.
- 最新來源 HEAD：`6574724aeac69c3f353fad5b2da90ccfab3714b1`.
- 上次 KING ES2M 來源快照：`b05f52591d7df60f90305d88d271b59086117397`.
- GitHub compare 結果：上游領先 5 commits，6 個變更路徑。
- 本輪只有 1 個 LPC Runtime 檔案、1 個 ES2M WebMUD 測試、4 個 WebMUD 前端檔案變更。
- 完整來源檔與 blob SHA 見 `source/es2m_updates/20261013_6574724/MANIFEST.md`.

## 本次同步結果

1. 六個上游變更檔已按原路徑封存於 `source/es2m_updates/20261013_6574724/`。
2. 最新 `cmds/std/sneak.c` 已同步到 `es2m_snapshot/mudlib/cmds/std/sneak.c`，作為 ES2M 來源證據，不代表已套用至遊戲 Runtime。
3. 其餘五個檔案屬於 ES2M WebMUD 前端／測試。KING 分支沒有相應的 ES2M WebMUD 前端目錄；因此完整封存但不把它們錯放進 KING LPC Runtime。
4. 不變更 Original ES2 固定來源，也不把 ES2-KDS 的行為當作 ES2M 主來源。
5. 已新增 KING Expansion `sneak.c` 相容性 adapter：以相同公式在檔案內實作 ES2M 的 `COMBAT_D->int_formula_exp(me)`，避免呼叫 Pinned Original 不存在的 daemon API；潛行準備階段與成功時的成長規則均保留。已新增 `scripts/test_es2m_sneak_progression.py`，並將其接入 Dockerfile 的 Expansion 後建置閘門。

## `sneak.c` 相容性

ES2M 更新包含兩個成長規則：
- 潛行準備階段改以 `query_attr("int")` 作為 `improve_skill("sneak", ...)` 的輸入。
- 潛行成功後改用 `COMBAT_D->int_formula_exp(me)` 計算經驗。

KING 固定的 Original ES2 Runtime combat daemon 未提供 `int_formula_exp()`；ES2M snapshot 中的 combat daemon 有此函式，但該快照不能直接當作 KING Runtime。因此已在 KING Expansion `sneak.c` 內以相同公式建立相容 adapter，不修改 Original ES2 固定來源。

## 驗證狀態

- ES2M 最新來源與 compare：PASS。
- 6 個變更檔封存：PASS。
- ES2M sneak source snapshot：已同步。
- KING Expansion adapter 與 targeted test gate：已寫入 GitHub；Oracle/Docker 實際執行結果待驗證。
- Docker build、Oracle gameplay、正式部署：未由本次 GitHub 封存操作驗證。
- PR #13：OPEN / NOT MERGED。
