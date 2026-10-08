#!/usr/bin/env bash
set -euo pipefail

APP_DIR="${APP_DIR:-$HOME/ES2-KING-MUD}"
BRANCH="${BRANCH:-build/original-es2-races-phase2}"
IMAGE="${IMAGE:-es2-king:oracle}"
CONTAINER="${CONTAINER:-es2-king}"
WEB_PORT="${WEB_PORT:-8080}"
DATA_DIR="${DATA_DIR:-$HOME/es2-king-data}"
ENV_FILE="${ENV_FILE:-$HOME/.config/es2-king/oracle.env}"
STATE_FILE="${STATE_FILE:-$HOME/.config/es2-king/oracle-deployed-head}"
FAST_DOCKERFILE="${FAST_DOCKERFILE:-$APP_DIR/deploy/oracle/Dockerfile.fast}"
VERIFY_RESTART="${VERIFY_RESTART:-1}"
SKIP_FETCH="${SKIP_FETCH:-0}"

mkdir -p "$DATA_DIR" "$(dirname "$ENV_FILE")" "$(dirname "$STATE_FILE")"
touch "$ENV_FILE"
chmod 600 "$ENV_FILE"

if [[ "$SKIP_FETCH" != "1" ]]; then
  git -C "$APP_DIR" fetch origin "$BRANCH"
fi
git -C "$APP_DIR" checkout -B "$BRANCH" "origin/$BRANCH"
new="$(git -C "$APP_DIR" rev-parse HEAD)"
short="${new:0:12}"

container_exists=0
old_image=""
if sudo docker inspect "$CONTAINER" >/dev/null 2>&1; then
  container_exists=1
  old_image="$(sudo docker inspect -f '{{.Image}}' "$CONTAINER")"
fi

deployed=""
if [[ -s "$STATE_FILE" ]]; then
  deployed="$(tr -d '[:space:]' < "$STATE_FILE")"
fi

mode="full"
changed=""

if [[ -n "$deployed" ]] && git -C "$APP_DIR" cat-file -e "$deployed^{commit}" 2>/dev/null    && git -C "$APP_DIR" merge-base --is-ancestor "$deployed" "$new"; then
  changed="$(git -C "$APP_DIR" diff --name-only "$deployed" "$new")"
  mode="none"
  while IFS= read -r path; do
    [[ -z "$path" ]] && continue
    case "$path" in
      deploy/oracle/update-fast.sh|deploy/oracle/Dockerfile.fast|scripts/test_m30_deployment_static.sh)
        ;;
      scripts/start_es2_king_web.sh|scripts/prepare_es2_persistence.sh|scripts/sync_es2_persistence.sh|scripts/healthcheck_es2_king.mjs|scripts/test_public_player_session_smoke.mjs|webtelnet/server.mjs|webtelnet/telnet.mjs|webtelnet/public/*)
        [[ "$mode" == "none" ]] && mode="fast"
        ;;
      *)
        mode="full"
        break
        ;;
    esac
  done <<< "$changed"
fi

if [[ "$mode" == "none" ]]; then
  printf '%s\n' "$new" > "$STATE_FILE"
  echo "ES2-KING FAST UPDATE：沒有 Runtime/Image 需要更新；HEAD=$new"
  exit 0
fi

if [[ "$mode" == "fast" ]] && [[ "$container_exists" -ne 1 || -z "$old_image" ]]; then
  mode="full"
fi

echo "ES2-KING UPDATE MODE：$mode"
echo "TARGET HEAD：$new"
if [[ -n "$deployed" ]]; then
  echo "DEPLOYED HEAD：$deployed"
fi

# Fast path 只允許已明列的啟動/Web 檔，先做最小語法驗證。
if [[ "$mode" == "fast" ]]; then
  bash -n     "$APP_DIR/scripts/start_es2_king_web.sh"     "$APP_DIR/scripts/prepare_es2_persistence.sh"     "$APP_DIR/scripts/sync_es2_persistence.sh"

  for js in     scripts/healthcheck_es2_king.mjs     scripts/test_public_player_session_smoke.mjs     webtelnet/server.mjs     webtelnet/telnet.mjs
  do
    sudo docker run --rm --entrypoint node       -v "$APP_DIR:/src:ro" "$old_image" --check "/src/$js" >/dev/null
  done
fi

# Docker image 名稱已含 tag（例如 es2-king:oracle）；候選 tag 應接在既有 tag 後，避免產生第二個冒號。
candidate="${IMAGE}-candidate-${short}"
sudo docker image rm "$candidate" >/dev/null 2>&1 || true

if [[ "$mode" == "fast" ]]; then
  sudo docker build     -f "$FAST_DOCKERFILE"     --build-arg "BASE_IMAGE=$old_image"     -t "$candidate"     "$APP_DIR"
else
  sudo docker build -t "$candidate" "$APP_DIR"
fi

run_container() {
  local image_ref="$1"
  sudo docker run -d --name "$CONTAINER" --restart unless-stopped     --env-file "$ENV_FILE"     -e PORT=8080     -e ES2_SAVE_DIR=/var/lib/es2-king/data     -e BUILD_COMMIT="$new"     -p "127.0.0.1:$WEB_PORT:8080"     -v "$DATA_DIR:/var/lib/es2-king/data"     "$image_ref" >/dev/null
}

wait_health() {
  local max="${1:-90}"
  for _ in $(seq 1 "$max"); do
    if curl -fsS "http://127.0.0.1:$WEB_PORT/health" >/dev/null 2>&1; then
      return 0
    fi
    sleep 2
  done
  return 1
}

rollback() {
  echo "FAST UPDATE FAIL：候選版本未通過，嘗試回復原映像。" >&2
  sudo docker rm -f "$CONTAINER" >/dev/null 2>&1 || true
  if [[ -n "$old_image" ]]; then
    run_container "$old_image"
    if wait_health 90; then
      echo "ROLLBACK PASS：已回復原映像。" >&2
    else
      echo "ROLLBACK FAIL：原映像也未恢復，請立即檢查 docker logs。" >&2
    fi
  fi
}

# 先完整 Build 候選映像，成功後才切換正式服務。
if [[ "$container_exists" -eq 1 ]]; then
  sudo docker stop -t 30 "$CONTAINER" >/dev/null || true
  sudo docker rm "$CONTAINER" >/dev/null 2>&1 || true
fi

if ! run_container "$candidate"; then
  rollback
  exit 1
fi

if ! wait_health 90; then
  sudo docker logs --tail 120 "$CONTAINER" >&2 || true
  rollback
  exit 1
fi

if [[ "$VERIFY_RESTART" == "1" ]]; then
  sudo docker restart "$CONTAINER" >/dev/null
  if ! wait_health 90; then
    sudo docker logs --tail 120 "$CONTAINER" >&2 || true
    rollback
    exit 1
  fi
fi

sudo docker tag "$candidate" "$IMAGE"
printf '%s\n' "$new" > "$STATE_FILE"

health="$(curl -fsS "http://127.0.0.1:$WEB_PORT/health")"
echo "ES2-KING ORACLE FAST UPDATE PASS：$new"
echo "MODE=$mode"
echo "HEALTH=$health"
