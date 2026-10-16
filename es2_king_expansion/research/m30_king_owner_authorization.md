# M30 KING Owner／Creator Authorization

> **[PROJECT-CANON / ES2-KING Expansion]**

`king` 是 ES2-KING 遊戲世界唯一的 `KING / Owner / Creator` 帳號。這是 Expansion Canon，不是 Original ES2 歷史設定。

## 授權鏈

`Original ES2 Login` → `Password Authentication（密碼驗證）` → `Account ID = king` → `KING Authorization（KING 授權）` → `Owner / Creator`

Display Name（顯示名稱）不參與授權。普通玩家即使顯示名稱為 `KING`、`King` 或相似文字，也不會取得 Owner 權限。一般 Administrator／Wizard 亦不會自動取得 KING 專屬指令。

## 權限層級

`KING / Owner / Creator` > `Administrator / Wizard` > `Player` > `NPC`

此層級只存在遊戲 Runtime（實際執行環境）。它不授予 Work Shell、OS Root、GitHub Token、GitHub Secrets、Cloud Credentials 或其他 Infrastructure Authority（基礎設施權限）。

## 密碼邊界

Owner 密碼只透過 Original ES2 正常登入流程建立及驗證。Repository、LPC、shell、Python、Markdown、Workflow 與測試 fixture 均不得保存 Alpha 明文密碼；公開伺服器上線前必須另行更換。
