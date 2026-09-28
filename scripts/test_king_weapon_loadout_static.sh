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

# Login provisioning 不得自動 wield；武器只進 Inventory。
if grep -n -A8 'provision_creator_weapons' "$APPLY" | grep -Eq '\.wield|->wield|call_other\([^)]*"wield"'; then
  echo "KING WEAPON LOADOUT STATIC FAIL: login contains auto-wield" >&2
  exit 1
fi

echo "KING WEAPON LOADOUT STATIC PASS"
