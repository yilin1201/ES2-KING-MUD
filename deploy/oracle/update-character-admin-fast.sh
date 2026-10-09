#!/usr/bin/env bash
set -euo pipefail

# ES2-KING 人物管理 V0 增量部署：不執行完整 Dockerfile，不重新建置整個遊戲。
APP_DIR="${APP_DIR:-$HOME/ES2-KING-MUD}"
BRANCH="${BRANCH:-build/original-es2-races-phase2}"
IMAGE="${IMAGE:-es2-king:oracle}"
CONTAINER="${CONTAINER:-es2-king}"
WEB_PORT="${WEB_PORT:-8080}"
DATA_DIR="${DATA_DIR:-$HOME/es2-king-data}"
ENV_FILE="${ENV_FILE:-$HOME/.config/es2-king/oracle.env}"
STATE_FILE="${STATE_FILE:-$HOME/.config/es2-king/oracle-character-admin-head}"
DOCKERFILE="${DOCKERFILE:-$APP_DIR/deploy/oracle/Dockerfile.character-admin-fast}"

# 只允許已存在的 Oracle 服務做增量更新，避免意外建立空白正式環境。
if ! sudo docker inspect "$CONTAINER" >/dev/null 2>&1; then
  echo "人物管理增量更新中止：找不到現有容器 $CONTAINER；未修改正式服務。" >&2
  exit 1
fi
if [[ ! -f "$ENV_FILE" || ! -f "$DOCKERFILE" ]]; then
  echo "人物管理增量更新中止：缺少 Oracle env 或增量 Dockerfile。" >&2
  exit 1
fi

# 只拉取指定開發分支，保留 Original ES2 保護與 PR 不 Merge 規則。
git -C "$APP_DIR" fetch origin "$BRANCH"
git -C "$APP_DIR" checkout -B "$BRANCH" "origin/$BRANCH"
new="$(git -C "$APP_DIR" rev-parse HEAD)"
short="${new:0:12}"

# Targeted source gate／人物管理專項檢查：只檢查 V0 欄位、權限、保存及命令接線。
# 不執行完整遊戲測試、不編譯 Original ES2 Driver。
bash "$APP_DIR/scripts/test_k_character_admin_v0_static_v2.sh"

old_image="$(sudo docker inspect -f '{{.Image}}' "$CONTAINER")"
old_build="$(sudo docker inspect -f '{{range .Config.Env}}{{println .}}{{end}}' "$CONTAINER" | sed -n 's/^BUILD_COMMIT=//p' | head -n 1)"
old_overlay="$(sudo docker inspect -f '{{range .Config.Env}}{{println .}}{{end}}' "$CONTAINER" | sed -n 's/^ES2_KING_CHARACTER_ADMIN_COMMIT=//p' | head -n 1)"
[[ -n "$old_build" ]] || old_build="existing-image"
candidate="${IMAGE%:*}-character-admin-${short}:${IMAGE##*:}"
sudo docker image rm "$candidate" >/dev/null 2>&1 || true

# Build incremental layer／增量映像：只複製管理 daemon 與命令，不執行整個遊戲 Dockerfile。
sudo docker build \
  -f "$DOCKERFILE" \
  --build-arg "BASE_IMAGE=$old_image" \
  --build-arg "CHARACTER_ADMIN_COMMIT=$new" \
  -t "$candidate" \
  "$APP_DIR"

# 確認候選映像內的主要指令及核心 daemon 都已放入。
sudo docker run --rm --entrypoint sh "$candidate" -c '
  set -eu
  test -f /opt/es2-king/runtime/mudlib/adm/daemons/kcharadmind.c
  test -f /opt/es2-king/runtime/mudlib/cmds/adm/kset.c
  test -f /opt/es2-king/runtime/mudlib/cmds/adm/kskill.c
  test -f /opt/es2-king/runtime/mudlib/cmds/adm/ksave.c
'

run_container() {
  local image_ref="$1" build_ref="$2" overlay_ref="$3"
  sudo docker run -d --name "$CONTAINER" --restart unless-stopped \
    --env-file "$ENV_FILE" \
    -e PORT=8080 \
    -e ES2_SAVE_DIR=/var/lib/es2-king/data \
    -e BUILD_COMMIT="$build_ref" \
    -e ES2_KING_CHARACTER_ADMIN_COMMIT="$overlay_ref" \
    -p "127.0.0.1:$WEB_PORT:8080" \
    -v "$DATA_DIR:/var/lib/es2-king/data" \
    "$image_ref" >/dev/null
}

wait_health() {
  local max="${1:-45}"
  for _ in $(seq 1 "$max"); do
    if curl -fsS "http://127.0.0.1:$WEB_PORT/health" >/dev/null 2>&1; then
      return 0
    fi
    sleep 2
  done
  return 1
}

rollback() {
  echo "人物管理增量更新失敗：回復原映像，玩家存檔 Volume 保持不變。" >&2
  sudo docker rm -f "$CONTAINER" >/dev/null 2>&1 || true
  run_container "$old_image" "$old_build" "$old_overlay"
  if wait_health 45; then
    echo "ROLLBACK PASS：原服務已恢復。" >&2
  else
    echo "ROLLBACK FAIL：請查看 sudo docker logs --tail 120 $CONTAINER" >&2
  fi
}

# 只替換容器映像；原玩家存檔掛載目錄不刪除、不搬動。
sudo docker stop -t 30 "$CONTAINER" >/dev/null || true
sudo docker rm "$CONTAINER" >/dev/null 2>&1 || true
if ! run_container "$candidate" "$old_build" "$new"; then
  rollback
  exit 1
fi
if ! wait_health 45; then
  sudo docker logs --tail 100 "$CONTAINER" >&2 || true
  rollback
  exit 1
fi

sudo docker tag "$candidate" "$IMAGE"
mkdir -p "$(dirname "$STATE_FILE")"
printf '%s\n' "$new" > "$STATE_FILE"
echo "ES2-KING CHARACTER ADMIN V0 INCREMENTAL UPDATE PASS"
echo "OVERLAY_COMMIT=$new"
echo "HEALTH=$(curl -fsS "http://127.0.0.1:$WEB_PORT/health")"
