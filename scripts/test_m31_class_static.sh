#!/usr/bin/env bash
set -euo pipefail

# M31 Class Static Regression／職業系統靜態回歸：只接受有證據的方士稱謂介面，
# 不把尚未回收的七職業公式、能力或門派條件補入 Runtime。
REPO_ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
RUNTIME="${1:-$REPO_ROOT/.runtime/game-completion-runtime}"
ORIGINAL_CLASS="$RUNTIME/mudlib/daemon/class"
RECONSTRUCTED_CLASS="$REPO_ROOT/es2_king_expansion/runtime/mudlib/daemon/class/alchemist.c"
EVIDENCE="$REPO_ROOT/original_es2/research/m31_class_runtime_completion.md"

fail() { echo "M31 CLASS STATIC FAIL：$*" >&2; exit 1; }

test -f "$ORIGINAL_CLASS/commoner.c" || fail "缺少 Original commoner.c"
test -f "$ORIGINAL_CLASS/fighter.c" || fail "缺少 Original fighter.c"
test -f "$RECONSTRUCTED_CLASS" || fail "缺少 alchemist 稱謂相容層"
test -f "$EVIDENCE" || fail "缺少 M31 Evidence 記錄"

grep -Fq 'return "平民"' "$ORIGINAL_CLASS/commoner.c" || fail "Original 平民稱謂不符"
grep -Fq 'return "武者"' "$ORIGINAL_CLASS/fighter.c" || fail "Original 武者稱謂不符"
grep -Fq '[ES2-KING Reconstruction]' "$RECONSTRUCTED_CLASS" || fail "方士相容層未標示 Reconstruction"
grep -Fq 'return "方士"' "$RECONSTRUCTED_CLASS" || fail "方士稱謂不符 Archived Evidence"

# Unknown Guard／未知項目保護：相容層不得偷偷加入成長、屬性、技能或戰鬥公式。
for forbidden in 'initialize(' 'advance_level(' 'set_attr(' 'set_skill(' 'gain_score(' 'valid_wield(' 'valid_wear(' 'kill_check(' 'brother_praise('; do
  if grep -Fq "$forbidden" "$RECONSTRUCTED_CLASS"; then
    fail "方士相容層含未經 Evidence 支持的介面：$forbidden"
  fi
done

for term in CONFIRMED_SOURCE ARCHIVED_SOURCE RECONSTRUCTION UNKNOWN SOURCE_REQUIRED 'commoner → apprentice → alchemist'; do
  grep -Fq "$term" "$EVIDENCE" || fail "Evidence 文件缺少邊界：$term"
done

echo 'M31 CLASS STATIC PASS：Original commoner/fighter 未改寫；alchemist 只恢復 Evidence 支持的方士稱謂，未知公式仍 UNKNOWN。'
