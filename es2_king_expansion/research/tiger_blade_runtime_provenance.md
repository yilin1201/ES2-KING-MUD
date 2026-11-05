# 虎紋刀 Runtime 來源與分類

## 用途

- `admin give /custom/weapon/blade/tiger_blade` 與 `admin setup` 需要此物件路徑。
- 本次 Neolith E2E 明確證實，既有 Runtime 未提供此路徑，導致 `admin setup` 在修改角色數值前安全中止。
- 因此將參考物件放入獨立 `es2_king_expansion/runtime/mudlib/custom/weapon/blade/tiger_blade.c`，讓 Expansion overlay 可以提供相容物件。

## 來源與可信度

- 參考來源：`kds121tw/ES2-KDS` 的 `source/upstream/mudlib/custom/weapon/blade/tiger_blade.c`
- 來源 URL：https://github.com/kds121tw/ES2-KDS/blob/rebuild/es2-game/source/upstream/mudlib/custom/weapon/blade/tiger_blade.c
- 來源 Blob SHA：`3e8585337c4bb327021b0277982e762063c754a0`
- 分類：**Reference Variant / KDS 參考版本**，不因該來源自稱 Original 就直接升格為 Annihilator Original ES2 Confirmed。
- 此檔是 Runtime 相容覆蓋，不覆寫 Original ES2 保存來源；如未來找到 Annihilator 原始碼中同一物件，應比對雜湊、內容與依賴後再更新可信度標記。

## 變更界線

- 保留參考來源的武器名稱、重量、傷害、雙手刀用途、描述及屬性加成。
- 不將此物件的設定宣稱為已驗證的 Original ES2 正統設定。
- 後續由 Neolith Driver 建置與 `admin setup` E2E 驗證實際載入、建立及裝備行為。
