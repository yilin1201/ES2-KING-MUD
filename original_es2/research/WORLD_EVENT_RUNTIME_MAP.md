# World Event Runtime Map（世界事件實機映射）

> 第五階段 5P。將世界房間依可觀察 Runtime 責任分類，避免把「找到 room」誤判成完整世界已恢復。

## Room types

| Type | Required evidence | Candidate example | Status |
|---|---|---|---|
| Navigation Room | path + short/long + exits | 一般道路／橋 | interface confirmed, content per-source |
| Event Room | room action + player state transition + completion/exit | 桃林 puzzle | CORROBORATED_RUNTIME_CANDIDATE |
| Class Guild Room | room + class daemon/NPC clone + class transition | 水煙閣正廳 | CORROBORATED_RUNTIME_CANDIDATE |
| School Room | school identity + master/NPC + path + exits | 冷梅莊 | SOURCE_REQUIRED for target Runtime |

## World reconstruction gate

單一房間只有在 path、inherit、short/long、exits、NPC/object clone（若有）逐欄可追時才可標示 room recovered。Event Room 另需 action/state transition；Class Guild/School Room 另需與 Class/Apprentice Source 對應。

目前冷梅莊只有名稱／門派／人物關係證據，不足以建立 `/d/lengmei/*`。桃林與水煙閣只作外部 ES2 family 架構候選，不直接替代目標歷史站地圖。
