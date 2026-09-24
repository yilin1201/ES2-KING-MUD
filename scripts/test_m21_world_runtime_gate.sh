#!/usr/bin/env bash
set -euo pipefail

# Runtime Gate／實機證據閘門：只讀 Bootstrap 後的 Original ES2 程式樹。
ROOT="${1:-.runtime/original-es2}"
WORLD="$ROOT/mudlib/d"
SNOW="$WORLD/snow"
test -d "$SNOW" || { echo "M21 RUNTIME FAIL：缺少保存區域 $SNOW"; exit 1; }

# 目前公開上游只確認 snow；若上游增加區域，先要求人工考證而不是靜默改寫基線。
mapfile -t areas < <(find "$WORLD" -mindepth 1 -maxdepth 1 -type d -printf '%f\n' | sort)
# Expansion Isolation／擴充隔離：Game Completion 的整合 Runtime 可包含已驗證的 M27 king Overlay，
# 但 Original 區域基線仍只能是 snow；任何其他目錄都必須重新考證。
mapfile -t original_areas < <(printf '%s\n' "${areas[@]}" | grep -vx 'king')
[[ "${#original_areas[@]}" -eq 1 && "${original_areas[0]}" == "snow" ]] || {
  echo "M21 RUNTIME FAIL：Original 區域清單已改變，需重新考證：${original_areas[*]}"; exit 1;
}
if [[ " ${areas[*]} " == *" king "* ]]; then
  test -f "$WORLD/king/wuji_realm.c" || { echo "M21 RUNTIME FAIL：king Overlay 缺少 M27 無極之境證據。"; exit 1; }
fi

all_c="$(find "$SNOW" -type f -name '*.c' | wc -l | tr -d ' ')"
root_c="$(find "$SNOW" -maxdepth 1 -type f -name '*.c' | wc -l | tr -d ' ')"
[[ "$all_c" -eq 99 ]] || { echo "M21 RUNTIME FAIL：區域全內容數已改變：$all_c"; exit 1; }
[[ "$root_c" -eq 43 ]] || { echo "M21 RUNTIME FAIL：房間候選數已改變：$root_c"; exit 1; }

for room in inn_hall inn_kitchen square_w square square_n square_s square_e square_sw small_temple ngate sgate egate wgate; do
  test -f "$SNOW/$room.c" || { echo "M21 RUNTIME FAIL：缺少核心房間 $room.c"; exit 1; }
done

# 已確認往返與中央路徑；只鎖定 Original 檔案中的真實出口。
grep -Fq '"west" : __DIR__"inn_kitchen"' "$SNOW/inn_hall.c"
grep -Fq '"east" : __DIR__"inn_hall"' "$SNOW/inn_kitchen.c"
grep -Fq '"east" : __DIR__"square_w"' "$SNOW/inn_hall.c"
grep -Fq '"east" : __DIR__"square"' "$SNOW/square_w.c"
grep -Fq 'inherit TEMPLE' "$SNOW/small_temple.c"

echo "M21 WORLD RUNTIME PASS／Original 保存區域=${original_areas[*]}，房間候選=$root_c，全內容程式=$all_c；已知 Expansion 區域保持隔離。"
