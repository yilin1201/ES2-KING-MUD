#!/usr/bin/env bash
set -euo pipefail

# Runtime Gate／實機證據閘門：核對乾淨 Original 上游的檔案及載入關係。
ROOT="${1:-.runtime/original-es2}"
SNOW="$ROOT/mudlib/d/snow"
NPC="$SNOW/npc"
test -d "$NPC/obj" || { echo "M22 RUNTIME FAIL：缺少 $NPC/obj"; exit 1; }

npc_count="$(find "$NPC" -maxdepth 1 -type f -name '*.c' | wc -l | tr -d ' ')"
npc_obj_count="$(find "$NPC/obj" -maxdepth 1 -type f -name '*.c' | wc -l | tr -d ' ')"
area_obj_count="$(find "$SNOW/obj" -maxdepth 1 -type f -name '*.c' | wc -l | tr -d ' ')"
[[ "$npc_count" -eq 23 ]] || { echo "M22 RUNTIME FAIL：NPC 數量已改變：$npc_count"; exit 1; }
[[ "$npc_obj_count" -eq 29 ]] || { echo "M22 RUNTIME FAIL：NPC 物品數量已改變：$npc_obj_count"; exit 1; }
[[ "$area_obj_count" -eq 3 ]] || { echo "M22 RUNTIME FAIL：區域物品數量已改變：$area_obj_count"; exit 1; }

# Inheritance／繼承關係：確認不同角色功能來自 Original 程式。
grep -Fq 'inherit F_SOLDIER' "$NPC/garrison.c"
grep -Fq 'inherit F_SOLDIER' "$NPC/lieutenant.c"
for vendor in yu waiter herbalist smith; do grep -Fq 'inherit F_VENDOR' "$NPC/$vendor.c"; done
grep -Fq 'inherit F_FIGHTER' "$NPC/girl.c"
grep -Fq 'inherit F_BANDIT' "$NPC/oldman.c"

# Room loading／房間載入：鎖定代表性 Original 相對路徑。
grep -Fq '__DIR__"npc/yu"' "$SNOW/bazar.c"
grep -Fq '__DIR__"npc/herbalist"' "$SNOW/herb_shop.c"
grep -Fq '__DIR__"npc/smith"' "$SNOW/smithy.c"
grep -Fq '__DIR__"npc/garrison"' "$SNOW/ngate.c"
grep -Fq '__DIR__"npc/lieutenant"' "$SNOW/ngate.c"
grep -Fq '__DIR__"npc/teacher"' "$SNOW/school.c"
grep -Fq '__DIR__"npc/alchemist"' "$SNOW/school.c"
grep -Fq '__DIR__"npc/foreman"' "$SNOW/store.c"
grep -Fq '__DIR__"npc/obj/wagon"' "$SNOW/store.c"
grep -Fq '__DIR__ "npc/obj/woodsword"' "$SNOW/fireplace.c"

echo "M22 NPC ITEM RUNTIME PASS／NPC=$npc_count，NPC物品=$npc_obj_count，區域物品=$area_obj_count。"
