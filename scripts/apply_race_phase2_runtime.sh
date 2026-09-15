#!/usr/bin/env bash
set -euo pipefail

ROOT="${1:-.runtime/original-es2}"
RACE_DIR="$ROOT/mudlib/daemon/race"
LOGIN="$ROOT/mudlib/adm/daemons/logind.c"

[[ -d "$RACE_DIR" && -f "$LOGIN" ]] || { echo "Race runtime not bootstrapped" >&2; exit 1; }

# ES2-KING Design: accelerated temporary birth-attribute baseline supplied by project owner.
# M6-M9 priority races = 50 for all eight attributes.
# Remaining historical selectable races = 25 for all eight attributes.
# This overlay is runtime preparation only; it does not claim these values are recovered Original ES2 formulas.
priority=(headless yaksa ashura rainnar)
other=(blackteeth human yenhold woochan dingling jiaojao malik)

zh_name() {
  case "$1" in
    headless) echo '形天';; yaksa) echo '夜叉';; ashura) echo '阿修羅';; rainnar) echo '雨師妾';;
    blackteeth) echo '黑齒';; human) echo '人類';; yenhold) echo '厭火';; woochan) echo '無腸';;
    dingling) echo '釘靈';; jiaojao) echo '焦僥';; malik) echo '巫首';;
  esac
}
karma() {
  case "$1" in
    blackteeth|human|yenhold|woochan) echo 5;; dingling|jiaojao) echo 10;; rainnar|headless) echo 25;; ashura|yaksa|malik) echo 30;;
  esac
}
write_race() {
  local id="$1" value="$2" zh k
  zh="$(zh_name "$id")"; k="$(karma "$id")"
  cat > "$RACE_DIR/$id.c" <<LPC
/* ES2-KING runtime reconstruction overlay.
 * Historical identity: $zh ($id)
 * Birth attributes: [ES2-KING Design] temporary baseline, not claimed Original formula.
 */
#define BASE_WEIGHT 40000
#include <statistic.h>
#include <race.h>
inherit HUMANOID;
private void create() {
    ::create(); seteuid(getuid()); set("karma", $k); set("civilized", 1);
    set("commoner_score_base", 100); DAEMON_D->register_race_daemon("$id");
}
void setup(object ob) {
    ::setup(ob); ob->set_default_object(__FILE__);
    if (!ob->query_weight()) ob->set_weight(BASE_WEIGHT);
}
void initialize(object ob) {
    ::initialize(ob);
    ob->init_attribute((["str":$value,"cps":$value,"int":$value,"spi":$value,"cor":$value,"dex":$value,"con":$value,"wis":$value]));
    ob->init_statistic((["gin":30,"kee":30,"sen":30]));
    if (!ob->query("age")) ob->set("age", 14 + random(4));
    ob->set_default_object(__FILE__);
}
LPC
}

for r in "${priority[@]}"; do write_race "$r" 50; done
for r in "${other[@]}"; do write_race "$r" 25; done

python3 - "$LOGIN" <<'PY'
from pathlib import Path
import sys,re
p=Path(sys.argv[1]); s=p.read_text()
races=['blackteeth','human','yenhold','woochan','dingling','jiaojao','rainnar','ashura','headless','yaksa','malik']
block='string *user_race = ({\n' + ''.join(f'    "{r}",\n' for r in races) + '});'
s,n=re.subn(r'string \*user_race = \(\{.*?\}\);',block,s,count=1,flags=re.S)
if n != 1: raise SystemExit('Could not replace user_race registry')
p.write_text(s)
PY

echo 'M6-M9 RUNTIME OVERLAY PASS: 11 historical races registered; M6-M9=50, remaining historical races=25.'
