#!/usr/bin/env bash
# M10 Original 種族靜態基線完整性測試。
# Baseline／基線：將已確認的網站數值轉成機器可讀資料，但尚不等同創角演算法。
set -euo pipefail

BASELINE="original_es2/research/original_race_runtime_baseline_m10.tsv"
test -f "$BASELINE"

# 去掉兩行中文說明與欄位標題後，必須剛好是 11 個種族。
count=$(grep -v '^#' "$BASELINE" | tail -n +2 | wc -l | tr -d ' ')
test "$count" = "11"

# 每個資料列必須有 14 欄：ID、中文名、業力、精氣神與八項屬性。
awk -F '\t' 'BEGIN{ok=1} /^#/ {next} NR==4 {next} NF!=14 {ok=0; print "欄位數錯誤: " $0 > "/dev/stderr"} END{exit ok?0:1}' "$BASELINE"

# 鎖定幾組差異最大的 Original 證據，避免再次被暫定全 25／50 覆蓋。
grep -q $'^headless\t刑天\t25\t80\t100\t30\t30\t20\t15\t10\t16\t24\t28\t18$' "$BASELINE"
grep -q $'^yaksa\t夜叉\t35\t140\t70\t70\t25\t25\t20\t25\t20\t25\t25\t25$' "$BASELINE"
grep -q $'^ashura\t阿修羅\t30\t80\t80\t80\t25\t40\t15\t25\t10\t20\t20\t20$' "$BASELINE"

echo 'M10 BASELINE PASS／基線通過：11 種族 Original 靜態資料可供 Runtime 重建使用。'
