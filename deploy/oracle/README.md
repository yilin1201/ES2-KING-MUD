# ES2-KING Oracle VM deployment

KING 專用部署。參考 ES2M 已驗證的 Oracle VM + Ubuntu 24.04 + Caddy/sslip.io 架構，但不讀寫 ES2M 主機或 Repository。

- Source: yilin1201/ES2-KING-MUD
- Branch: build/original-es2-races-phase2
- Runtime: existing KING Dockerfile (single source of truth)
- Public: Caddy 443 -> localhost:8080
- Neolith TCP 4000 remains internal only
- Persistence: local volume plus existing Neon DATABASE_URL when configured
- Secrets: put DATABASE_URL and ES2_KING_CLAIM_TOKEN in ~/.config/es2-king/oracle.env; never commit them.

Oracle Security List should expose SSH 22 and HTTP/HTTPS 80/443. Do not expose 4000. 8080 is bound to 127.0.0.1 only.

First install:
  bash deploy/oracle/setup.sh
  bash deploy/oracle/https.sh

Update:
  bash deploy/oracle/update.sh
