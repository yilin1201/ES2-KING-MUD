#!/usr/bin/env bash
set -euo pipefail
APP_DIR="${APP_DIR:-$HOME/ES2-KING-MUD}"
BRANCH="${BRANCH:-build/original-es2-races-phase2}"
IMAGE="${IMAGE:-es2-king:oracle}"
CONTAINER="${CONTAINER:-es2-king}"
WEB_PORT="${WEB_PORT:-8080}"
DATA_DIR="${DATA_DIR:-$HOME/es2-king-data}"
ENV_FILE="${ENV_FILE:-$HOME/.config/es2-king/oracle.env}"

old="$(git -C "$APP_DIR" rev-parse HEAD)"
git -C "$APP_DIR" fetch origin "$BRANCH"
git -C "$APP_DIR" checkout -B "$BRANCH" "origin/$BRANCH"
new="$(git -C "$APP_DIR" rev-parse HEAD)"
echo "KING $old -> $new"

sudo docker build -t "$IMAGE" "$APP_DIR"
sudo docker rm -f "$CONTAINER" >/dev/null 2>&1 || true
sudo docker run -d --name "$CONTAINER" --restart unless-stopped \
  --env-file "$ENV_FILE" -e PORT=8080 -e ES2_SAVE_DIR=/var/lib/es2-king/data \
  -p "127.0.0.1:$WEB_PORT:8080" -v "$DATA_DIR:/var/lib/es2-king/data" "$IMAGE"
for _ in $(seq 1 90); do
  curl -fsS "http://127.0.0.1:$WEB_PORT/health" >/dev/null 2>&1 && { echo "ES2-KING ORACLE UPDATE PASS: $new"; exit 0; }
  sleep 2
done
sudo docker logs --tail 100 "$CONTAINER" >&2 || true
exit 1
