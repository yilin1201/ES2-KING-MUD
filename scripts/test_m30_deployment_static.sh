#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

node --check webtelnet/server.mjs
node --check scripts/healthcheck_es2_king.mjs
node --check scripts/test_m30_deployment_smoke.mjs
bash -n scripts/start_es2_king_web.sh scripts/prepare_es2_persistence.sh scripts/test_m30_persistence_paths.sh
bash scripts/test_es2_cn_standard.sh

grep -Fq 'EXPOSE 8080' Dockerfile
! grep -Eq 'EXPOSE[[:space:]]+4000' Dockerfile
grep -Fq 'process.env.PORT || process.env.WEBTELNET_PORT || 8080' webtelnet/server.mjs
grep -Fq 'location.protocol === "https:" ? "wss:" : "ws:"' webtelnet/public/index.html
grep -Fq 'healthCheckPath: /health' render.yaml

echo "M30 DEPLOYMENT STATIC（M30 部署靜態檢查）：PASS（測試通過）；Web 連接埠、WSS（加密 WebSocket）、Health Check（健康檢查）與 Telnet 對外暴露邊界均通過。"
