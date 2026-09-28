# ES2-KING K Admin Tools

- KING Owner: khome, kcreate, kcanon, kmartial, kadmin.
- Wizard: kroom, kexit, kmap, kact, kwhere, knpc, kitem.
- Arch: Wizard set + kgoto, kobj, ktrace, kbroken, kmiss.
- Player command `k` remains untouched; this change does not create or replace `k`.
- Existing `kinghome/kingcreate/kingcanon/kingmartial` remain as compatibility commands.
- K-team roles are intentionally separate from Original ES2 `wiz_status`; only KING Owner may change K-team roles through kadmin.
- Runtime inspection never claims that add_action/conditional source can be reconstructed from object state. Such cases are marked STATIC SOURCE ANALYSIS REQUIRED.

## 2026-09-28 True Driver Validation

隔離 `king`／`kprobe` 已由真實 Neolith Driver 完成：KING Owner login、permission-filtered `help k`／`help wiz`、Wizard 授權、Arch 升級、remove、save／quit／relogin 與 Player denial。

Runtime markers：

- `K_ADMIN_RUNTIME_PASS`
- `K_HELP_RUNTIME_PASS`
- `K_PERMISSION_REGRESSION_PASS`

Original global alias `k → kill` 由 Runtime 實際輸入 `k` 驗證，仍回覆 Original「你想殺誰」；新增 `help k` 不會取代命令解析時的 kill alias。

地圖工具只分類 `VISIBLE / RAW EXIT`、`MISSING`、`BROKEN`；`add_action()`、`valid_leave()`、`move()`、`call_other()` 與 Quest Trigger 統一標記 `STATIC SOURCE ANALYSIS REQUIRED`。本階段沒有建立 Missing Room、出口或 Quest Content。
