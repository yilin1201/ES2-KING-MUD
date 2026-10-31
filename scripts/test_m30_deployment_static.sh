#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

node --check webtelnet/server.mjs
node --check webtelnet/telnet.mjs
node --check scripts/healthcheck_es2_king.mjs
node --check scripts/test_m30_deployment_smoke.mjs
node --check scripts/test_m30_king_reservation_e2e.mjs
node --check scripts/test_m30_king_claim_e2e.mjs
node --check scripts/test_m30_claim_browser_input.mjs
node scripts/test_m30_claim_browser_input.mjs
node --check scripts/test_m30_character_browser_input.mjs
node scripts/test_m30_character_browser_input.mjs
node scripts/test_m30_webtelnet_display.mjs
node scripts/test_m30_mobile_responsive.mjs
node scripts/test_m30_desktop_centering.mjs
bash -n scripts/start_es2_king_web.sh scripts/prepare_es2_persistence.sh scripts/sync_es2_persistence.sh scripts/assert_m30_final_runtime.sh scripts/test_m30_final_runtime_permissions.sh scripts/test_m30_persistence_paths.sh scripts/test_m30_king_reservation_e2e.sh scripts/test_m30_king_claim_e2e.sh scripts/test_m30_production_equivalent_king_reservation.sh
bash -n deploy/oracle/update-fast.sh
grep -Fq 'ARG BASE_IMAGE=es2-king:oracle' deploy/oracle/Dockerfile.fast
grep -Fq 'ES2-KING UPDATE MODE' deploy/oracle/update-fast.sh
grep -Fq 'sudo docker stop -t 30' deploy/oracle/update-fast.sh
grep -Fq 'ROLLBACK PASS' deploy/oracle/update-fast.sh
bash scripts/test_es2_cn_standard.sh

grep -Fq 'EXPOSE 8080' Dockerfile
! grep -Eq 'EXPOSE[[:space:]]+4000' Dockerfile
mkdir_line="$(grep -n '^RUN mkdir -p' Dockerfile | cut -d: -f1)"
chown_line="$(grep -n '&& chown -R es2king:es2king' Dockerfile | cut -d: -f1)"
test -n "$mkdir_line" && test -n "$chown_line" && (( mkdir_line < chown_line ))
mkdir_block="$(sed -n '/^RUN mkdir -p/,/&& chown -R es2king:es2king/p' Dockerfile)"
for directory in mudlib/bin mudlib/data mudlib/log; do
  grep -Fq "/opt/es2-king/runtime/$directory" <<<"$mkdir_block"
done
grep -Fq '&& chown es2king:es2king /opt/es2-king/runtime/mudlib' Dockerfile
grep -Fq 'process.env.PORT || process.env.WEBTELNET_PORT || 8080' webtelnet/server.mjs
grep -Fq 'location.protocol === "https:" ? "wss:" : "ws:"' webtelnet/public/index.html
grep -Fq 'healthCheckPath: /health' render.yaml
grep -Fq 'branch: build/original-es2-races-phase2' render.yaml
# Secret Injection／秘密注入：Blueprint 必須要求 Render 端提供 Claim Token，禁止把值寫進 Repository。
grep -A1 -F 'key: ES2_KING_CLAIM_TOKEN' render.yaml | grep -Fq 'sync: false'
! grep -Eq 'ES2_KING_CLAIM_TOKEN:[[:space:]]*[^[:space:]]' render.yaml
grep -Fq 'build_commit: buildCommit' webtelnet/server.mjs
grep -Fq 'pathname === "/health"' webtelnet/server.mjs
grep -Fq 'bash scripts/assert_m30_final_runtime.sh /opt/es2-king/runtime' Dockerfile
grep -Fq 'bash "$SCRIPT_DIR/assert_m30_final_runtime.sh" "$RUNTIME_DIR"' scripts/start_es2_king_web.sh
grep -Fq 'rm -f \\' scripts/start_es2_king_web.sh
grep -Fq '"$RUNTIME_DIR/mudlib/bin/adm/daemons/logind.b" \\' scripts/start_es2_king_web.sh
grep -Fq '"$RUNTIME_DIR/mudlib/bin/adm/daemons/cmd_d.b"' scripts/start_es2_king_web.sh
grep -Fq 'chmod --reference="$LOGIN_D" "$temp_login"' scripts/apply_es2_king_expansion.sh
grep -Fq 'chmod go+r "$LOGIN_D"' scripts/apply_es2_king_expansion.sh
grep -Fq 'mudlib/bin/adm/daemons/logind.b' scripts/apply_es2_king_expansion.sh
grep -Fq 'mudlib/bin/adm/daemons/cmd_d.b' scripts/apply_es2_king_expansion.sh
grep -Fq 'ES2-KING OWNER COMMAND REHASH' scripts/apply_es2_king_expansion.sh
grep -Fq 'input_to("get_owner_claim", 3, ob)' scripts/apply_es2_king_expansion.sh
# Original LPC Compatibility／舊 Driver 相容：Race callback 不得再引入較新 LPC 的負索引切片。
! grep -Fq 'race[<1]' scripts/apply_es2_king_expansion.sh
! grep -Fq 'race[0..<2]' scripts/apply_es2_king_expansion.sh
grep -Fq 'owner_claim_transport_decode(token)' scripts/apply_es2_king_expansion.sh
grep -Fq 'Claim 安全診斷：' scripts/apply_es2_king_expansion.sh
grep -Fq 'ES2-KING PUBLIC CHARACTER TEXT INPUT' scripts/apply_es2_king_expansion.sh
# Race Line Input／種族整行輸入：部署前即鎖定 Public、Runtime、E2E 三者使用相同契約。
grep -Fq 'input_to ("get_race", 0, ob)' scripts/apply_es2_king_expansion.sh
test "$(grep -Fc 'input_to ("get_race", 0, ob);' scripts/apply_es2_king_expansion.sh)" -eq 2
# Race Callback ABI／種族回呼介面：首次輸入與 retry 都必須把 ob 當第三參數傳給 callback。
! grep -Fq 'input_to ("get_race", ob)' scripts/apply_es2_king_expansion.sh
! grep -Fq 'callback 的額外參數。\\n' scripts/apply_es2_king_expansion.sh
grep -Fq '["1", "human", "人類"].includes(value)' webtelnet/public/character-input.mjs
grep -Fq 'return { bytes: "ES2RACE:1", followup: null }' webtelnet/public/character-input.mjs
grep -Fq 'return { bytes: "ES2RACE:2", followup: null }' webtelnet/public/character-input.mjs
grep -Fq '["1", "2", "human", "人類", "avatar"].includes(choice)' webtelnet/public/index.html
grep -Fq 'socket.send("ES2RACE:" + raceChoice)' webtelnet/public/index.html
grep -Fq '["ES2RACE:1", "ES2RACE:2", "ES2RACE:human", "ES2RACE:avatar"].includes(incoming)' webtelnet/server.mjs
grep -Fq 'Runtime Adaptive Race' webtelnet/server.mjs
grep -Fq 'choice === "1" || choice === "2" ? choice : race' webtelnet/server.mjs
grep -Fq '+ "\r\n", "utf8"))' webtelnet/server.mjs
grep -Fq 'race-telnet-crlf-v9' webtelnet/server.mjs
grep -Fq 'characterMenuFor("請輸入編號 1 或 2: ")' scripts/test_m30_character_browser_input.mjs
! grep -Fq 'socket.send(choice === "人類" ? "human" : choice)' webtelnet/public/index.html
grep -Fq 'if (sendCharacterChoice(choice))' webtelnet/public/index.html
grep -Fq 'browser-to-mud bytes=' webtelnet/server.mjs
grep -Fq 'mud.write(Buffer.from(data))' webtelnet/server.mjs
grep -Fq 'runtimeTail = (runtimeTail + text).slice(-1024)' webtelnet/server.mjs
grep -Fq 'mud.write(Buffer.from("\r", "utf8"))' webtelnet/server.mjs
grep -Fq 'prepareOwnerClaim(command.value)' webtelnet/public/index.html
grep -Fq '至少需要 ${MINIMUM_OWNER_CLAIM_BYTES} bytes，尚未送出' webtelnet/public/index.html
grep -Fq 'pathname === "/claim-input.mjs"' webtelnet/server.mjs
grep -Fq 'pathname === "/claim-input.mjs" || pathname === "/character-input.mjs"' webtelnet/server.mjs

echo "M30 DEPLOYMENT STATIC（M30 部署靜態檢查）：PASS（測試通過）；Web 連接埠、WSS（加密 WebSocket）、Health Check（健康檢查）與 Telnet 對外暴露邊界均通過。"
