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
node scripts/test_m30_webtelnet_display.mjs
node scripts/test_m30_mobile_responsive.mjs
node scripts/test_m30_desktop_centering.mjs
bash -n scripts/start_es2_king_web.sh scripts/prepare_es2_persistence.sh scripts/assert_m30_final_runtime.sh scripts/test_m30_final_runtime_permissions.sh scripts/test_m30_persistence_paths.sh scripts/test_m30_king_reservation_e2e.sh scripts/test_m30_king_claim_e2e.sh scripts/test_m30_production_equivalent_king_reservation.sh
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
grep -Fq 'build_commit: buildCommit' webtelnet/server.mjs
grep -Fq 'pathname === "/health"' webtelnet/server.mjs
grep -Fq 'bash scripts/assert_m30_final_runtime.sh /opt/es2-king/runtime' Dockerfile
grep -Fq 'bash "$SCRIPT_DIR/assert_m30_final_runtime.sh" "$RUNTIME_DIR"' scripts/start_es2_king_web.sh
grep -Fq 'chmod --reference="$LOGIN_D" "$temp_login"' scripts/apply_es2_king_expansion.sh
grep -Fq 'chmod go+r "$LOGIN_D"' scripts/apply_es2_king_expansion.sh
grep -Fq 'mudlib/bin/adm/daemons/logind.b' scripts/apply_es2_king_expansion.sh
grep -Fq 'mudlib/bin/adm/daemons/cmd_d.b' scripts/apply_es2_king_expansion.sh
grep -Fq 'ES2-KING OWNER COMMAND REHASH' scripts/apply_es2_king_expansion.sh
grep -Fq 'input_to("get_owner_claim", 3, ob)' scripts/apply_es2_king_expansion.sh
grep -Fq 'owner_claim_transport(secret)' scripts/apply_es2_king_expansion.sh
grep -Fq 'encodeOwnerClaim(command.value)' webtelnet/public/index.html

echo "M30 DEPLOYMENT STATIC（M30 部署靜態檢查）：PASS（測試通過）；Web 連接埠、WSS（加密 WebSocket）、Health Check（健康檢查）與 Telnet 對外暴露邊界均通過。"
