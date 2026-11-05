#!/usr/bin/env bash
set -euo pipefail

REPO_URL="${REPO_URL:-https://github.com/yilin1201/ES2-KING-MUD.git}"
BRANCH="${BRANCH:-build/original-es2-races-phase2}"
APP_DIR="${APP_DIR:-$HOME/ES2-KING-MUD}"
IMAGE="${IMAGE:-es2-king:oracle}"
CONTAINER="${CONTAINER:-es2-king}"
WEB_PORT="${WEB_PORT:-8080}"
DATA_DIR="${DATA_DIR:-$HOME/es2-king-data}"
ENV_FILE="${ENV_FILE:-$HOME/.config/es2-king/oracle.env}"

. /etc/os-release
if [[ "${ID:-}" != "ubuntu" ]] || dpkg --compare-versions "${VERSION_ID:-0}" lt 24.04; then
  echo "需要 Ubuntu 24.04 以上。" >&2; exit 1
fi

sudo apt-get update -y
sudo apt-get install -y ca-certificates curl git docker.io
sudo systemctl enable --now docker
sudo usermod -aG docker "$USER" || true
mkdir -p "$DATA_DIR" "$(dirname "$ENV_FILE")"
touch "$ENV_FILE"
chmod 600 "$ENV_FILE"

if [[ -d "$APP_DIR/.git" ]]; then
  git -C "$APP_DIR" fetch origin "$BRANCH"
  git -C "$APP_DIR" checkout -B "$BRANCH" "origin/$BRANCH"
else
  git clone --branch "$BRANCH" "$REPO_URL" "$APP_DIR"
fi

sudo docker build -t "$IMAGE" "$APP_DIR"
sudo docker rm -f "$CONTAINER" >/dev/null 2>&1 || true
sudo docker run -d --name "$CONTAINER" --restart unless-stopped \
  --env-file "$ENV_FILE" \
  -e PORT=8080 -e ES2_SAVE_DIR=/var/lib/es2-king/data \
  -p "127.0.0.1:$WEB_PORT:8080" \
  -v "$DATA_DIR:/var/lib/es2-king/data" \
  "$IMAGE"

for _ in $(seq 1 90); do
  if curl -fsS "http://127.0.0.1:$WEB_PORT/health" >/dev/null 2>&1; then
    echo "ES2-KING ORACLE READY"
    echo "HEAD=$(git -C "$APP_DIR" rev-parse HEAD)"
    echo "Local=http://127.0.0.1:$WEB_PORT"
    exit 0
  fi
  sleep 2
done
sudo docker logs --tail 100 "$CONTAINER" >&2 || true
exit 1
