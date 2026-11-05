#!/usr/bin/env bash
set -euo pipefail
WEB_PORT="${WEB_PORT:-8080}"
IP="$(curl -fsS --max-time 5 https://ifconfig.me)"
DOMAIN="${1:-$(echo "$IP" | tr . -).sslip.io}"
sudo apt-get update -y
sudo apt-get install -y caddy
sudo tee /etc/caddy/Caddyfile >/dev/null <<EOF
$DOMAIN {
  encode gzip
  reverse_proxy 127.0.0.1:$WEB_PORT
}
EOF
sudo systemctl enable caddy >/dev/null 2>&1 || true
sudo systemctl restart caddy
echo "KING HTTPS target: https://$DOMAIN/"
