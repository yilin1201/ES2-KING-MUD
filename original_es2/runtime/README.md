# Original ES2 Executable Runtime

## 目的

這個目錄記錄 ES2-KING 從「資料考證」進入「實際可執行 MUD」的工程流程。

第一個執行目標不是自行重寫 Driver，也不是把 Expansion 混入 Original，而是先證明 Annihilator 現行 Original ES2 Mudlib 能在乾淨環境中被 Neolith 啟動，再以此建立 ES2-KING 的可重現測試基線。

## 已確認上游執行方式

[Confirmed]

上游 `taedlar/es2_mudlib` 的 `main` 為 ES2 Mudlib v1.5+，需要 Neolith。上游把 Neolith 設為 Git submodule，並要求使用 `--recurse-submodules` 取得 Mudlib + Driver。

上游 `neolith.conf` 的重要預設：

- MudlibDir = `mudlib`
- MudName = `Eastern Stories II`
- Port = `4000:telnet`
- MasterFile = `/adm/obj/master.c`
- SimulEfunFile = `/adm/obj/simul_efun.c`

Neolith 支援 console mode；啟動參數為 `-c`。這讓第一階段可以先在主機終端完成登入與基本指令測試，不必先處理手機 MUD Client。

## Bootstrap

ES2-KING 提供：

`scripts/bootstrap_original_es2.sh`

用途：

1. 建立獨立 `.runtime/original-es2` 工作目錄。
2. 從 `taedlar/es2_mudlib` clone Original ES2。
3. 同時取得 Neolith submodule。
4. 保持上游原始碼與 ES2-KING 研究/擴充檔案分離。

這個 runtime 目錄由 `.gitignore` 排除，不把整份上游 Mudlib 當成 ES2-KING 自己撰寫的程式碼提交。

## Linux 建置需求

依 Neolith 官方 INSTALL：

- build-essential
- ninja-build
- bison
- cmake >= 3.28

第一階段建議關閉 unit-test dependency，先縮短 Driver boot 驗證路徑：

```bash
cd .runtime/original-es2/neolith
cmake --preset linux-gcc -DBUILD_TESTING=OFF
cmake --build --preset dev-linux-gcc
```

建置成功後，使用產生的 `neolith` 執行檔搭配 ES2 根目錄的 `neolith.conf` 啟動；第一輪優先使用 console mode：

```bash
<neolith executable> -f neolith.conf -c
```

## M0 驗收

目前仍不可標記「Driver 成功啟動」。只有實際執行後確認：

1. Neolith process 成功啟動。
2. Master object 載入。
3. SimulEfun 載入。
4. Mudlib 沒有 fatal startup error。
5. console 或 telnet 能進入 ES2 login flow。

才更新 `original_es2/tests/minimum_playable_milestone.md`。

## 後續

M0 通過後依序驗證：

`Connect → Login → Create Character → Human/Commoner/Lv1 → Room → look → score → move`

Original M1–M4 穩定後，才開始把 ES2-KING 刑天等 Expansion 接入測試 runtime。
