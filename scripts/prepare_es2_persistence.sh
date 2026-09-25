#!/usr/bin/env bash
set -euo pipefail

RUNTIME_DIR="${ES2_RUNTIME_DIR:-/opt/es2-king/runtime}"
SAVE_DIR="${ES2_SAVE_DIR:-/var/lib/es2-king/data}"
SEED_DIR="${ES2_DATA_SEED_DIR:-$RUNTIME_DIR/mudlib/data.seed}"
RUNTIME_DATA="$RUNTIME_DIR/mudlib/data"
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

test -d "$RUNTIME_DIR/mudlib" || {
  echo "PERSISTENCE FAIL：找不到 Runtime mudlib：$RUNTIME_DIR/mudlib" >&2
  exit 1
}
mkdir -p "$SAVE_DIR"

# 有 DATABASE_URL 時由 Neon/Lakebase Postgres 提供跨 Render 容器永久 backing store。
if [[ -n "${DATABASE_URL:-}" ]]; then
  echo "ES2 PERSISTENCE MODE：NEON（跨容器保存由 Lakebase Postgres 提供）"
elif [[ "${ES2_PERSISTENCE_MODE:-ephemeral}" == "persistent" ]]; then
  echo "ES2 PERSISTENCE MODE：PERSISTENT（跨部署保存由外部持久磁碟提供）"
else
  echo "ES2 PERSISTENCE MODE：EPHEMERAL（本次 Runtime 內可保存；重新部署後帳號資料可能重建）"
fi

# Neolith save_object() 的實際目標固定保留在 MudlibDir 內，禁止跨 sandbox symlink。
if [[ -L "$RUNTIME_DATA" ]]; then
  legacy_target="$(readlink "$RUNTIME_DATA")"
  test -d "$legacy_target" || {
    echo "PERSISTENCE FAIL：舊 data symlink 目標不存在：$legacy_target" >&2
    exit 1
  }
  unlink "$RUNTIME_DATA"
  mkdir -p "$RUNTIME_DATA"
  cp -a "$legacy_target/." "$RUNTIME_DATA/"
elif [[ ! -d "$RUNTIME_DATA" ]]; then
  mkdir -p "$RUNTIME_DATA"
fi

# Image seed 與同容器 backing 先恢復，再由 Neon durable snapshot 覆蓋為最新永久狀態。
if [[ -d "$SEED_DIR" ]]; then
  cp -a --update=none "$SEED_DIR/." "$RUNTIME_DATA/"
fi
if [[ "$SAVE_DIR" != "$RUNTIME_DATA" ]] && find "$SAVE_DIR" -mindepth 1 -print -quit | grep -q .; then
  cp -a "$SAVE_DIR/." "$RUNTIME_DATA/"
fi

# Durable Restore Gate：DATABASE_URL 已配置時，Driver 接受登入前必須完成 Neon restore。
# DB 不可達直接 fail closed，避免空角色覆蓋永久資料；exit 3 代表首次尚無 snapshot。
if [[ -n "${DATABASE_URL:-}" ]]; then
  set +e
  python3 "$SCRIPT_DIR/es2_neon_persistence.py" download --target "$RUNTIME_DATA"
  restore_rc=$?
  set -e
  if [[ $restore_rc -ne 0 && $restore_rc -ne 3 ]]; then
    echo "PERSISTENCE FAIL：Neon durable restore 未完成，拒絕啟動 Driver。" >&2
    exit "$restore_rc"
  fi
fi

mkdir -p "$RUNTIME_DATA/login" "$RUNTIME_DATA/user" "$RUNTIME_DATA/mail"
for letter in {a..z}; do
  mkdir -p "$RUNTIME_DATA/login/$letter" "$RUNTIME_DATA/user/$letter" "$RUNTIME_DATA/mail/$letter"
done

bash "$SCRIPT_DIR/sync_es2_persistence.sh"
echo "ES2 PERSISTENCE READY：Runtime=$RUNTIME_DATA；Backing=$SAVE_DIR"
