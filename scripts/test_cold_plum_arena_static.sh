#!/usr/bin/env bash
set -euo pipefail
ROOT="${1:-.runtime/es2-king}"
NPC="$ROOT/mudlib/d/arena/npc/mei_hanshuang.c"
ROOM="$ROOT/mudlib/d/arena/yanwujie.c"
test -f "$NPC";test -f "$ROOM"
grep -Fq '"/d/arena/npc/mei_hanshuang" : 1' "$ROOM"
for a in str cor int spi cps dex con wis;do grep -Fq "set_attr(\"$a\", 50)" "$NPC";done
for sk in "hainmay force" advance_lunmay lunmay mayin seven force sword parry dodge unarmed;do grep -Fq "set_skill(\"$sk\", 300)" "$NPC";done
! grep -Eq '1900|1850|35%|480000|360000|320000' "$NPC"
echo "COLD PLUM ARENA STATIC PASS：八屬性=50；冷梅 Evidence Skill 與基本 Combat usage=300；未導入 Gemini 模擬倍率。"
