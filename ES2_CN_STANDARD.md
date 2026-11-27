# ES2-CN 繁體中文工程溝通標準

本文件是 ES2-KING M0～M30 與後續維護工作的正式溝通規範。目標讀者包含不具程式開發背景的 Owner（專案擁有者）。

## 1. Owner 閱讀優先原則

英文技術名詞、英文縮寫、Command（執行指令）、Test（測試）、Runtime Status（執行狀態）在每一份新文件或新報告第一次出現時，必須同時回答：

1. 英文是什麼；
2. 繁體中文名稱是什麼；
3. 它在 ES2-KING 裡的白話用途是什麼。

同一份文件後續重複出現時可以使用簡稱。不得要求 Owner 自行查詢英文意義。

## 2. Command（執行指令）格式

所有 Command（執行指令）、Shell Command（命令列指令）、Git Command（Git 版本控制指令）、Docker Command（容器指令）、Runtime Command（遊戲執行環境指令）與 Deployment Command（部署指令），第一次出現時使用以下格式：

```text
docker build
中文：建立 Docker 容器映像檔。
用途：把 ES2-KING、Neolith、Web Client 與 Bridge 所需環境打包成可以部署到伺服器的映像檔。
```

```text
docker run
中文：啟動 Docker 容器。
用途：實際啟動剛建立好的 ES2-KING 執行環境。
```

指令若放在 code block（程式碼區塊）中，中文名稱與用途必須緊鄰於區塊之前或之後。

## 3. 工程作業名稱

| 英文 | 繁體中文名稱 | ES2-KING 白話用途 |
|---|---|---|
| Build | 建置 | 將原始程式轉換成可以執行的程式。 |
| Boot | 啟動 | 真正啟動 Neolith Driver 與 ES2-KING。 |
| Deploy | 部署 | 將已完成的 ES2-KING 放到外部主機上執行。 |
| Health Check | 健康檢查 | 確認 Web、Bridge、Neolith 三個服務目前是否正常運作。 |
| Smoke Test | 冒煙測試 | 使用最短測試流程確認部署後的主要服務真的能運作。 |
| Regression Test | 回歸測試 | 確認本次修改沒有破壞以前已正常的功能。 |
| Persistence | 資料持久化 | 確保玩家角色與 KING 存檔在伺服器重新啟動後仍能保留。 |
| External Deployment | 外部部署 | 將遊戲放到 Owner 的 Chrome、Edge 或 iPhone 可以連線的外部伺服器。 |

## 4. 狀態碼

| 狀態碼 | 必須附加的繁體中文說明 |
|---|---|
| `PASS` | 測試通過 |
| `FAIL` | 測試失敗，需要查明原因 |
| `COMPLETE` | 已完成 |
| `PARTIAL` | 部分完成 |
| `UNKNOWN` | 目前證據不足，尚無法確認 |
| `BLOCKED` | 受到外部條件阻擋 |
| `ENVIRONMENT-LIMITATION` | 執行環境限制，不代表程式本身失敗 |
| `ACTIONS-INFRA-BLOCKED` | GitHub 自動測試受到帳號／基礎設施限制，並非程式測試失敗 |
| `PERSISTENCE-HOSTING-LIMITATION` | 主機無持久磁碟，因此重新部署後玩家存檔可能消失 |
| `OWNER DEVICE ACCEPTANCE REQUIRED` | 需要 Owner 使用自己的裝置完成最終驗收 |

報告不得只寫狀態碼。例如必須寫成 `PASS（測試通過）`。

## 5. 網址與網路技術

| 英文／縮寫 | 繁體中文名稱與用途 |
|---|---|
| HTTP | 網頁傳輸協定；瀏覽器與 Web 服務交換資料的基本方式。 |
| HTTPS | 加密網頁傳輸協定；Owner 使用 Chrome／Edge 開啟正式遊戲網頁時使用。 |
| WebSocket | 網頁雙向即時通訊；讓瀏覽器與 MUD 即時交換文字指令。 |
| WSS | 加密 WebSocket；HTTPS 網頁正式連線時使用。 |
| localhost／127.0.0.1 | 本機位址；只能連到目前這台伺服器自己。 |
| 0.0.0.0:$PORT | 公開 Web 服務監聽位置；讓 Hosting 平台把外部 HTTPS 流量送入 Web Client／Bridge。 |

## 6. 遊戲指令

| 指令 | 繁體中文名稱與用途 |
|---|---|
| `look` | 查看目前場景。 |
| `score` | 查看角色狀態。 |
| `inventory` | 查看身上物品。 |
| `save` | 儲存角色資料。 |
| `quit` | 離開遊戲。 |
| `kingrealm` | KING 神域指令；進入天神殿・無極之境。 |
| `kingcreate` | KING 創世指令；執行 Owner／Creator 專屬創造功能。 |
| `kingmartial` | KING 武學管理指令；管理 ES2-KING Expansion 武學功能。 |
| `kingcanon` | KING Canon 管理指令；管理 ES2-KING Expansion 正式設定功能。 |

## 7. 程式碼註解

所有新增或修改的重要程式邏輯必須加入繁體中文註解，尤其包含：

- Login（登入）；
- Authentication（身分驗證）；
- Authorization（權限授權）與 KING 權限；
- Save（存檔）與 Persistence（資料持久化）；
- WebSocket（網頁雙向即時通訊）；
- Telnet Bridge（Telnet 轉接橋梁）；
- Deployment（部署）；
- Security Boundary（安全權限邊界）。

Original ES2 preserved source（Original ES2 保存原始碼）不得只為增加中文註解而修改。Original 與 ES2-KING Expansion 必須永久分離。

## 8. 最終報告格式

不得只回報 `Docker Build PASS`。必須使用下列形式：

```text
Docker Build（Docker 容器建置）：PASS（測試通過）
已成功把 ES2-KING 所需執行環境建立成 Docker Image（Docker 容器映像檔）。
```

沒有實際執行的測試不得標記 `PASS（測試通過）`；外部環境限制必須使用對應限制狀態，不得冒充程式成功或失敗。
