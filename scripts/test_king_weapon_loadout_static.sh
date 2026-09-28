#!/usr/bin/env bash
set -euo pipefail

ROOT="${1:-.}"
OBJ="$ROOT/es2_king_expansion/runtime/mudlib/obj/king"
KINGD="$ROOT/es2_king_expansion/runtime/mudlib/adm/daemons/kingd.c"
APPLY="$ROOT/scripts/apply_es2_king_expansion.sh"

for f in guxiao feiyun guxiao_feiyun blood_blade god_cane; do
  test -f "$OBJ/$f.c"
done

grep -Fq 'set("wield_as", ({ "sword", "secondhand sword" }))' "$OBJ/guxiao.c"
grep -Fq 'set("wield_as", ({ "sword", "secondhand sword" }))' "$OBJ/feiyun.c"
grep -Fq 'set("wield_as", ({ "sword", "twohanded sword" }))' "$OBJ/guxiao_feiyun.c"
grep -Fq 'setup_blade(3, 12, 90, 5)' "$OBJ/blood_blade.c"
grep -Fq 'set("wield_as", "blade")' "$OBJ/blood_blade.c"
grep -Fq '"daxie qisun blade": 10' "$OBJ/blood_blade.c"
grep -Fq '"parry": 10' "$OBJ/blood_blade.c"
grep -Fq 'setup_staff(2, 16, 150, 10)' "$OBJ/god_cane.c"
grep -Fq 'set("wield_as", "twohanded staff")' "$OBJ/god_cane.c"
grep -Fq 'provision_creator_weapons' "$KINGD"
grep -Fq 'provision_creator_weapons' "$APPLY"

# Evidence Boundary Gate／避免在沒有直接 Original/Historical 證據前，
# 把武器 channel 自動推導成門派武學 mapping。
! grep -Fq 'map_skill("secondhand sword", "advance_lunmay")' "$KINGD"
! grep -Fq 'map_skill("twohanded staff", "chin_staff")' "$KINGD"
! grep -Fq 'call_other(actor, "map_skill", "secondhand sword", "advance_lunmay")' "$KINGD"
! grep -Fq 'call_other(actor, "map_skill", "twohanded staff", "chin_staff")' "$KINGD"

# Login provisioning 不得自動 wield；武器只進 Inventory。
if grep -n -A8 'provision_creator_weapons' "$APPLY" | grep -Eq '\.wield|->wield|call_other\([^)]*"wield"'; then
  echo "KING WEAPON LOADOUT STATIC FAIL: login contains auto-wield" >&2
  exit 1
fi

echo "KING WEAPON LOADOUT STATIC PASS"

# Targeted Runtime E2E entrypoint／只要求可手動執行入口存在，不建立高頻 Actions。
test -f "$ROOT/scripts/test_king_weapon_runtime_e2e.sh"
test -f "$ROOT/scripts/test_king_weapon_runtime_e2e.mjs"
grep -Fq 'KING_WEAPON_RUNTIME_E2E_PASS' "$ROOT/scripts/test_king_weapon_runtime_e2e.mjs"
