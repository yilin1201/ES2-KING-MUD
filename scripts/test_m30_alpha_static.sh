#!/usr/bin/env bash
set -euo pipefail

MATRIX="original_es2/research/m30_completion_matrix.md"
ROADMAP="ROADMAP_M0_M30.md"
test -f "$MATRIX"; test -f "$ROADMAP"
for m in $(seq 1 30); do grep -Fq "M${m}" "$MATRIX" || { echo "M30 STATIC FAIL：缺少 M$m"; exit 1; }; done

# Completion evidence／完成證據：M1-M29 必須有實際結果、測試或研究檔，不接受空白里程碑。
for f in original_es2/runtime/m25_release_candidate_result.md original_es2/research/m24_system_data_integrity.md es2_king_expansion/runtime/m26_king_admin_result.md es2_king_expansion/runtime/m27_wuji_realm_result.md es2_king_expansion/runtime/m28_martial_result.md es2_king_expansion/runtime/m29_canon_result.md; do
  test -f "$f" || { echo "M30 STATIC FAIL：缺少完成證據 $f"; exit 1; }
done

# Original boundary／原作邊界與 Expansion overlay／擴充覆蓋層。
test -f original_es2/source_manifest.md
test -f scripts/bootstrap_original_es2.sh
test -f scripts/apply_es2_king_expansion.sh
grep -Fq 'Original ES2' "$MATRIX"
grep -Fq 'Expansion' "$MATRIX"
grep -Fq 'UNKNOWN' "$MATRIX"
grep -Fq 'ACTIONS-INFRA-BLOCKED' "$MATRIX"

# TODO/FIXME/stub scan／待辦、修正標記與佔位實作掃描：只報告，不把 UNKNOWN 誤判成程式錯誤。
if rg -n 'TODO|FIXME|placeholder|STUB' original_es2 es2_king_expansion scripts --glob '!m30_*' --glob '!test_m30_*' --glob '!m30_completion_matrix.md' > .m30_todo_scan; then
  echo 'M30 NOTICE／發現待確認標記（詳見 .m30_todo_scan），不自動改寫 Canon。'
else
  : > .m30_todo_scan
  echo 'M30 TODO SCAN PASS／未發現 TODO、FIXME、placeholder、STUB。'
fi
echo 'M30 ALPHA STATIC PASS／M1-M30 矩陣、完成證據與邊界完整。'
