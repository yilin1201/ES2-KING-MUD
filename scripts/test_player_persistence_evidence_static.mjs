#!/usr/bin/env node
// ES2-KING 普通玩家與永久存檔的離線證據邊界測試。
// 僅檢查測試入口及必要防護；不連線、不建立帳號、不宣稱 Gameplay PASS。
import assert from "node:assert/strict";
import fs from "node:fs";
const read = path => fs.readFileSync(path, "utf8");
const publicGate = read("scripts/test_public_player_acceptance.mjs");
const session = read("scripts/test_public_player_session_smoke.mjs");
const deploy = read("scripts/test_m30_deployment_smoke.mjs");
const alpha = read("scripts/test_player_open_alpha_e2e.mjs");
const persistence = read("scripts/test_m30_persistence_paths.sh");
const prepare = read("scripts/prepare_es2_persistence.sh");
const sync = read("scripts/sync_es2_persistence.sh");
assert.match(publicGate, /base\.protocol !== "https:"/, "PUBLIC Gate 必須拒絕非 HTTPS");
assert.match(publicGate, /40-char expected build commit/, "PUBLIC Gate 必須鎖定完整 Build SHA");
assert.match(publicGate, /PUBLIC_PLAYER_SESSION_PASS:external-wss-new-player-confirmation:no-account-created/, "PUBLIC Gate 必須驗證外部 WSS 普通玩家標記");
assert.match(session, /doesNotMatch\(output, \/目前權限:/, "普通玩家檢查不得接受管理權限");
assert.match(session, /no-account-created/, "Smoke 不得默默建立正式帳號");
assert.match(deploy, /ES2_EXPECT_BUILD_COMMIT/, "部署驗收必須核對 Build SHA");
assert.match(alpha, /assert\\.match\\(entered, \\/目前權限: \\\\(player\\\\)\\/\\)/, "E2E 必須直接斷言普通玩家權限，不可只檢查零散文字");
assert.match(persistence, /unset DATABASE_URL/, "離線持久化測試不得連正式 Neon");
assert.match(persistence, /process restart|Process Restart/i, "應涵蓋程序重啟還原");
assert.match(persistence, /sync_es2_persistence\.sh/, "應涵蓋 Runtime 回寫");
assert.match(prepare, /es2_neon_persistence\.py" download/, "有 DATABASE_URL 時應有還原入口");
assert.match(sync, /es2_neon_persistence\.py" upload/, "有 DATABASE_URL 時應有同步入口");
console.log("PLAYER_PERSISTENCE_EVIDENCE_STATIC_PASS (source gates only; Runtime UNKNOWN)");
