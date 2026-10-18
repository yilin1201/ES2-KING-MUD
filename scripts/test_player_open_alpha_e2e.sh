#!/usr/bin/env bash
# Player Open Alpha／普通玩家開放測試：建立全空 data Runtime，禁止使用預建玩家 save 或管理權限。
set -euo pipefail

REPO_ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
SOURCE_RUNTIME="${1:-$REPO_ROOT/.runtime/game-completion-runtime}"
DRIVER_BIN="$(realpath "${ES2_DRIVER_BIN:-$SOURCE_RUNTIME/neolith/out/build/linux/src/Debug/neolith}")"
TEMP_ROOT="$(mktemp -d)"
WEB_PORT="$((50000 + $$ % 500))"
TEST_PASSWORD="$(openssl rand -hex 16)"
# Port Contract 診斷值先初始化，避免失敗清理階段因未設定變數而中斷。
MUD_PORT=""
CONFIG_PORT=""
driver_pid=""
bridge_pid=""

cleanup() {
  status=$?
  if (( status != 0 )); then
    echo "PLAYER OPEN ALPHA FAIL：暫存 Runtime 保留於 $TEMP_ROOT" >&2
    # 先記錄清理前的程序狀態，再送出終止訊號，避免將清理造成的 core dump 當成根因。
    if [[ -n "$driver_pid" ]]; then
      if kill -0 "$driver_pid" 2>/dev/null; then
        echo "診斷：E2E 失敗時 Driver 仍存活；清理程序現在才會終止它，後續 Aborted/core dump 不單獨視為啟動崩潰證據。" >&2
      else
        echo "診斷：Driver 在清理前已退出；需依 driver.stdout/debug.log 判斷是否為真正啟動失敗。" >&2
      fi
    fi
    echo "診斷：globals.h MUD_PORT=${MUD_PORT:-UNKNOWN}；neolith.conf Port=${CONFIG_PORT:-UNKNOWN}。" >&2
    echo "診斷：Driver host=127.0.0.1 port=${MUD_PORT:-UNKNOWN}；Bridge upstream=127.0.0.1:${MUD_PORT:-UNKNOWN}；WebSocket URL=ws://127.0.0.1:${WEB_PORT}/mud。" >&2
    echo "診斷：globals.h 存在=$([[ -f "$TEMP_ROOT/mudlib/include/globals.h" ]] && echo yes || echo no)；neolith.conf 存在=$([[ -f "$TEMP_ROOT/neolith.conf" ]] && echo yes || echo no)。" >&2
    for log in "$TEMP_ROOT/driver.stdout" "$TEMP_ROOT/bridge.stdout" "$TEMP_ROOT/player-open-alpha.log"; do
      if [[ -r "$log" ]]; then
        echo "----- 診斷日誌：$log（最後 100 行）-----" >&2
        tail -n 100 "$log" >&2 || true
      fi
    done
    while IFS= read -r -d '' log; do
      echo "----- MUD debug/runtime log：$log（最後 80 行）-----" >&2
      tail -n 80 "$log" >&2 || true
    done < <(find "$TEMP_ROOT" -maxdepth 5 -type f \( -iname 'debug.log' -o -path '*/mudlib/log/*' \) -print0 2>/dev/null)
  fi
  [[ -z "$bridge_pid" ]] || kill "$bridge_pid" 2>/dev/null || true
  [[ -z "$driver_pid" ]] || kill "$driver_pid" 2>/dev/null || true
  wait "$bridge_pid" 2>/dev/null || true
  wait "$driver_pid" 2>/dev/null || true
  if (( status == 0 )); then rm -rf -- "$TEMP_ROOT"; fi
  return "$status"
}
trap cleanup EXIT INT TERM

test -x "$DRIVER_BIN"
cp -a "$SOURCE_RUNTIME/mudlib" "$TEMP_ROOT/mudlib"
cp "$SOURCE_RUNTIME/neolith.conf" "$TEMP_ROOT/neolith.conf"
if [[ "${ES2_RUNTIME_ALREADY_OVERLAID:-0}" == "1" ]]; then
  echo "PLAYER OPEN ALPHA: using pre-overlaid source Runtime; skipped duplicate overlay application."
else
  bash "$REPO_ROOT/scripts/apply_race_phase2_runtime.sh" "$TEMP_ROOT"
  bash "$REPO_ROOT/scripts/apply_es2_king_expansion.sh" "$TEMP_ROOT"
  bash "$REPO_ROOT/scripts/apply_combat_balance_instrumentation.sh" "$TEMP_ROOT"
fi

# Fresh Data／全新資料：此 E2E 不複製任何 login/user fixture。
# ES2M Port Contract／從隔離 Runtime 讀取實際連接埠，不得硬編碼舊版 4000。
test -f "$TEMP_ROOT/mudlib/include/globals.h" || { echo 'PLAYER OPEN ALPHA BLOCKED：缺少 globals.h。' >&2; exit 1; }
test -f "$TEMP_ROOT/neolith.conf" || { echo 'PLAYER OPEN ALPHA BLOCKED：缺少 neolith.conf。' >&2; exit 1; }
MUD_PORT="$(awk '$1 == "#define" && $2 == "MUD_PORT" { print $3; exit }' "$TEMP_ROOT/mudlib/include/globals.h")"
CONFIG_PORT="$(awk '$1 == "Port" { split($2, p, ":"); print p[1]; exit }' "$TEMP_ROOT/neolith.conf")"
if [[ ! "$MUD_PORT" =~ ^[0-9]+$ || "$CONFIG_PORT" != "$MUD_PORT" ]]; then
  echo "PLAYER OPEN ALPHA BLOCKED：連接埠不一致（globals.h=$MUD_PORT, neolith.conf=$CONFIG_PORT）。" >&2
  exit 1
fi
PORT_HEX="$(printf '%04X' "$MUD_PORT")"
echo "PLAYER OPEN ALPHA PORT CONTRACT PASS: mudlib=$MUD_PORT config=$CONFIG_PORT driver_host=127.0.0.1 driver_port=$MUD_PORT"

rm -rf -- "$TEMP_ROOT/mudlib/data"
mkdir -p "$TEMP_ROOT/mudlib/data/login"/{a..z} "$TEMP_ROOT/mudlib/data/user"/{a..z} "$TEMP_ROOT/mudlib/log"

# Security Gate／安全閘門：測試帳號不得存在 wizlist，也不允許測試腳本加入權限。
for id in kinglook avataropen; do
  ! grep -Eq "^${id}[[:space:]]" "$TEMP_ROOT/mudlib/adm/etc/wizlist"
done

(cd "$TEMP_ROOT"; exec "$DRIVER_BIN" -f neolith.conf) >"$TEMP_ROOT/driver.stdout" 2>&1 &
driver_pid=$!
# Readiness Gate／以核心 listener 狀態確認 Driver 就緒，避免 connect-and-close 探測造成額外副作用。
driver_ready=0
for _ in {1..300}; do
  if ! kill -0 "$driver_pid" 2>/dev/null; then
    echo 'PLAYER OPEN ALPHA BLOCKED：Neolith 在 listener ready 前已退出。' >&2
    tail -n 100 "$TEMP_ROOT/driver.stdout" >&2 || true
    exit 1
  fi
  if awk -v port=":$PORT_HEX" 'NR > 1 && $2 ~ (port "$") && $4 == "0A" { found=1 } END { exit !found }' /proc/net/tcp /proc/net/tcp6 2>/dev/null; then
    driver_ready=1
    break
  fi
  sleep 0.1
done
if (( driver_ready == 0 )); then
  echo "PLAYER OPEN ALPHA BLOCKED：等待 Neolith listener timeout（host=127.0.0.1 port=$MUD_PORT）。" >&2
  tail -n 100 "$TEMP_ROOT/driver.stdout" >&2 || true
  exit 1
fi
(cd "$REPO_ROOT/webtelnet"; ES2_HOST=127.0.0.1 ES2_PORT="$MUD_PORT" PORT="$WEB_PORT" exec node server.mjs) >"$TEMP_ROOT/bridge.stdout" 2>&1 &
bridge_pid=$!
ES2_TEST_PORT="$WEB_PORT" node -e 'const h=require("http"),d=Date.now()+10000;(function p(){h.get({host:"127.0.0.1",port:+process.env.ES2_TEST_PORT,path:"/health"},r=>{r.resume();r.statusCode===200?process.exit(0):Date.now()<d?setTimeout(p,100):process.exit(1)}).on("error",()=>Date.now()<d?setTimeout(p,100):process.exit(1))})()'

LOG="$TEMP_ROOT/player-open-alpha.log"
ES2_E2E_WS_URL="ws://127.0.0.1:$WEB_PORT/mud" ES2_E2E_PASSWORD="$TEST_PASSWORD" \
  node "$REPO_ROOT/scripts/test_player_open_alpha_e2e.mjs" | tee "$LOG"

for marker in \
  ORIGINAL_PLAYER_CREATION_HUMAN_E2E_PASS \
  PLAYER_COLD_LOGIN_INVENTORY_PASS:kinglook \
  PLAYER_COLD_LOGIN_INVENTORY_PASS:avataropen \
  PLAYER_RELOGIN_FIRST_COMMAND_INVENTORY_PASS:kinglook \
  PLAYER_RELOGIN_FIRST_COMMAND_INVENTORY_PASS:avataropen \
  ORIGINAL_PLAYER_CREATION_AVATAR_E2E_PASS \
  PLAYER_AVATAR_WORLD_PASS:movement-npc-inventory \
  PLAYER_SECURITY_BOUNDARY_PASS \
  PLAYER_EQUIPMENT_UNEQUIP_PASS:kinglook:unwield-inventory-rewield \
  PLAYER_COMBAT_RECOVERY_PASS:kinglook:command-and-movement-after-sparring \
  PLAYER_CLASS_PASS:kinglook:alchemist \
  PLAYER_ES2M_SHOP_QUANTITY_PASS:leeopen:ordinary-source-money-atomic-delivery-persistence-ready \
  PLAYER_ES2M_SHOP_MULTI_VENDOR_PASS:leeopen:snow-fish-lee-grocery \
  PLAYER_FOOD_CAPACITY_PASS:leeopen:full-stat-rejection-item-retained \
  PLAYER_ES2M_WATERSKIN_DRINK_PASS:leeopen:source-route-value-unit-liquid \
  PLAYER_ES2M_SHOP_ITEM_PERSISTENCE_PASS:ordinary-save-quit-relogin \
  PLAYER_ES2M_SHOP_BALANCE_PERSISTENCE_PASS:ordinary-save-quit-relogin \
  PLAYER_ES2M_SHOP_NONSTACK_PERSISTENCE_PASS:fur-hat-waterskin-no-duplicates \
  PLAYER_FULL_JOURNEY_E2E_PASS
do
  grep -Fq "$marker" "$LOG" || { echo "PLAYER OPEN ALPHA FAIL：缺少 $marker" >&2; exit 1; }
done

# Shop Acceptance Matrix／商店驗收矩陣：只有上列普通玩家 Runtime markers 全數存在後才輸出 PASS。
# 每列都指向本次 E2E log 的實際證據，不以 Static／Mock 取代 Gameplay。
cat <<'EOF'
SHOP_ACCEPTANCE:NPC_REACHABLE:PASS:PLAYER_ES2M_SHOP_MULTI_VENDOR_PASS
SHOP_ACCEPTANCE:LIST:PASS:PLAYER_ES2M_SHOP_MULTI_VENDOR_PASS
SHOP_ACCEPTANCE:BUY:PASS:PLAYER_ES2M_SHOP_QUANTITY_PASS
SHOP_ACCEPTANCE:BULK_BUY:PASS:PLAYER_ES2M_SHOP_QUANTITY_PASS
SHOP_ACCEPTANCE:INVENTORY:PASS:PLAYER_ES2M_SHOP_ITEM_PERSISTENCE_PASS
SHOP_ACCEPTANCE:SAVE_QUIT_RELOGIN:PASS:PLAYER_ES2M_SHOP_ITEM_PERSISTENCE_PASS
SHOP_ACCEPTANCE:INVALID_QUANTITY:PASS:PLAYER_ES2M_SHOP_QUANTITY_PASS
SHOP_ACCEPTANCE:INSUFFICIENT_MONEY:PASS:PLAYER_ES2M_SHOP_QUANTITY_PASS
SHOP_ACCEPTANCE:INSUFFICIENT_STOCK:PASS:PLAYER_ES2M_SHOP_QUANTITY_PASS
SHOP_ACCEPTANCE:DELIVERY_FAILURE:PASS:PLAYER_ES2M_SHOP_QUANTITY_PASS
SHOP_ACCEPTANCE:NO_DUPLICATE_NONSTACK:PASS:PLAYER_ES2M_SHOP_NONSTACK_PERSISTENCE_PASS
SHOP_ACCEPTANCE:BALANCE_PERSISTENCE:PASS:PLAYER_ES2M_SHOP_BALANCE_PERSISTENCE_PASS
EOF

# Save Evidence／存檔證據：由 Driver 從零建立，不接受 fixture 或畫面文字替代。
for id in kinglook avataropen; do
  initial="${id:0:1}"
  test -s "$TEMP_ROOT/mudlib/data/login/$initial/$id.o"
  test -s "$TEMP_ROOT/mudlib/data/user/$initial/$id.o"
  grep -Fq '"level":1' "$TEMP_ROOT/mudlib/data/user/$initial/$id.o"
done
grep -Fq '"race":"human"' "$TEMP_ROOT/mudlib/data/user/k/kinglook.o"
grep -Fq '"class":"alchemist"' "$TEMP_ROOT/mudlib/data/user/k/kinglook.o"
grep -Fq '"name":"KING"' "$TEMP_ROOT/mudlib/data/user/k/kinglook.o"
grep -Fq '"race":"avatar"' "$TEMP_ROOT/mudlib/data/user/a/avataropen.o"
grep -Fq '"class":"commoner"' "$TEMP_ROOT/mudlib/data/user/a/avataropen.o"

BALANCE_LOG="$TEMP_ROOT/mudlib/log/combat_balance"
if test -s "$BALANCE_LOG"; then
  node "$REPO_ROOT/scripts/parse_combat_balance_log.mjs" "$BALANCE_LOG" > "$TEMP_ROOT/combat-balance-baseline.json"
  grep -Eq '"samples": [1-9][0-9]*' "$TEMP_ROOT/combat-balance-baseline.json"
  echo "PLAYER_COMBAT_DAMAGE_BASELINE_PASS:source-backed-wooden-sword:$(tr -d '\n' < "$TEMP_ROOT/combat-balance-baseline.json")"
else
  # Combat Gameplay 已由普通玩家實際比武 + recovery 驗證；observer benchmark 是後續調平衡證據，
  # 不得因觀測檔缺失把已完成的 Gameplay Journey 誤標為不可玩，也不得補造 damage sample。
  echo 'PLAYER_COMBAT_DAMAGE_BASELINE_PENDING:no-observer-sample:no-fabricated-damage'
fi

if grep -En '編譯時段錯誤|Runtime error|Cannot #include|Undefined variable|Undefined function' "$TEMP_ROOT/driver.stdout"; then
  echo 'PLAYER OPEN ALPHA FAIL：Driver Log 存在編譯／執行錯誤。' >&2
  exit 1
fi

echo 'PLAYER_OPEN_ALPHA_LOCAL_RUNTIME_PASS：12 Race 創角另有獨立 Gate；本 Gate 驗證全新 Human／Avatar、普通玩家世界／NPC／物品／裝備／戰鬥、Alchemist、save／quit／relogin。'

