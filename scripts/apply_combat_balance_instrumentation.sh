#!/usr/bin/env bash
# Combat Balance Instrumentation／只在隔離 Runtime 建立觀測點；不得改變 Original 傷害公式。
set -euo pipefail
TARGET="${1:?usage: apply_combat_balance_instrumentation.sh <runtime-root>}"
FILE="$TARGET/mudlib/feature/char/combat.c"
test -f "$FILE"
MARK='ES2-KING COMBAT BALANCE OBSERVER'
grep -Fq "$MARK" "$FILE" && { echo 'COMBAT_BALANCE_INSTRUMENTATION_PASS:already-applied'; exit 0; }
python3 - "$FILE" <<'PY'
from pathlib import Path
import sys
p=Path(sys.argv[1]); s=p.read_text()
needle='''    kill_mode = objectp(attacker) ? attacker->is_killing(this_object()) : 0;
    from_type = objectp(from) ? from->query("material") : "unknown";
'''
replacement='''    kill_mode = objectp(attacker) ? attacker->is_killing(this_object()) : 0;
    from_type = objectp(from) ? from->query("material") : "unknown";

    // ES2-KING COMBAT BALANCE OBSERVER／純觀測：只記錄 post-resistance actual damage。
    // 此 patch 只套用到 mktemp isolated Runtime；Production 不套用，因此不需要 runtime flag。
    log_file("combat_balance",
        sprintf("ES2BALANCE damage=%d kill=%d target=%s attacker=%s source=%s\\n",
            damage,
            kill_mode,
            query("id") || "unknown",
            objectp(attacker) ? (string)attacker->query("id") : "unknown",
            objectp(from) ? file_name(from) : "unknown"));
'''
if needle not in s: raise SystemExit("找不到 Pinned Original receive_damage anchor")
p.write_text(s.replace(needle,replacement,1))
PY
rm -f "$TARGET/mudlib/bin/feature/char/combat.b"
grep -Fq "$MARK" "$FILE"
echo 'COMBAT_BALANCE_INSTRUMENTATION_PASS:receive_damage-observer-only'
