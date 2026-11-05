# M26 KING 管理員／創世系統

> `[ES2-KING Expansion]` `[Project Canon]`

## 目標

KING Creation Service（KING 創造服務：讓最高管理員從受控清單建立擴充物件）沿用 Original ES2 的 `(admin)` 權限階層，提供 `kingcreate` 指令與白名單 Registry（登錄表：只列出允許建立的項目）。

## 安全邊界

- `SECURED_ADMIN_COMMAND`（安全管理指令檢查）阻擋一般玩家、間接物件呼叫與非最高管理員。
- `kingd` Daemon（常駐服務物件）再次驗證 `interactive` 與 `(admin)` 等級，形成雙層權限檢查。
- 使用固定 `creation_registry`，不得從玩家輸入直接載入任意檔案路徑。
- 第一個登錄項目 `creation_mark`／創世印記只作最小端到端驗收，不推定 M27～M29 的場景、武學或神兵功能。

## Original／Expansion 分離

程式只存在 `es2_king_expansion/runtime/mudlib`，由 `apply_es2_king_expansion.sh` 套入獨立 `.runtime/es2-king`。Original ES2 保存來源與 `.runtime/original-es2` 不接受這些檔案。

## Runtime Gate／執行閘門

1. Expansion Overlay（擴充覆蓋層）能套用到獨立 Runtime。
2. Driver（驅動器）可載入 `kingd`、`kingcreate` 與 `creation_mark`。
3. 一般玩家呼叫遭拒；最高 `(admin)` 可列出並建立創世印記。
4. 任意路徑與未登錄 ID 必須失敗。

## UNKNOWN（未知）

尚未由既有 Canon 明確定義的 KING 指令、召喚清單、創世資源消耗、審計格式與 M27～M29 實體功能保持 `UNKNOWN`，不因完成 M26 而補造。
