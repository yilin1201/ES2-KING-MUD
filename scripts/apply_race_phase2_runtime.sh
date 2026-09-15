#!/usr/bin/env bash
set -euo pipefail

# Runtime overlay／執行環境覆蓋層：只在測試用 Runtime 產生歷史種族，不改寫保存的 Original ES2 原始證據。
ROOT="${1:-.runtime/original-es2}"
RACE_DIR="$ROOT/mudlib/daemon/race"
LOGIN="$ROOT/mudlib/adm/daemons/logind.c"

# Bootstrap／建立執行環境：必須先由 bootstrap_original_es2.sh 準備好 Original ES2 Runtime。
[[ -d "$RACE_DIR" && -f "$LOGIN" ]] || { echo "Race runtime not bootstrapped／種族執行環境尚未建立" >&2; exit 1; }

# [ES2-KING Design／ES2-KING 暫定設計]
# M6-M9 priority races／優先種族：八項出生屬性暫定全部為 50。
# Other reconstructed historical races／其他重建歷史種族：八項出生屬性暫定全部為 25。
# Human 與 Avatar 已有 Original ES2 程式及 M2/M5 實測基準，因此絕對不由本覆蓋層重寫。
priority=(headless yaksa ashura rainnar)
other=(blackteeth yenhold woochan dingling jiaojao malik)

# zh_name／中文種族名稱：使用已考證的 Original ES2 中文名稱。
zh_name() {
  case "$1" in
    headless) echo '形天';; yaksa) echo '夜叉';; ashura) echo '阿修羅';; rainnar) echo '雨師妾';;
    blackteeth) echo '黑齒';; yenhold) echo '厭火';; woochan) echo '無腸';;
    dingling) echo '釘靈';; jiaojao) echo '焦僥';; malik) echo '巫首';;
  esac
}

# karma／業值：依歷史選角資料建立 Runtime 重建值，不推導未考證的額外能力。
karma() {
  case "$1" in
    blackteeth|yenhold|woochan) echo 5;; dingling|jiaojao) echo 10;; rainnar|headless) echo 25;; ashura|yaksa|malik) echo 30;;
  esac
}

# write_race／寫入重建種族：產生 Runtime-only（僅執行環境使用）的 LPC 種族 Daemon（常駐系統物件）。
write_race() {
  local id="$1" value="$2" zh k
  zh="$(zh_name "$id")"; k="$(karma "$id")"
  cat > "$RACE_DIR/$id.c" <<LPC
/* ES2-KING Runtime reconstruction overlay／ES2-KING 執行環境重建覆蓋層。
 * Historical identity／歷史種族：$zh ($id)
 * Birth attributes／出生屬性：[ES2-KING Design] 暫定基礎值，不宣稱為已還原的 Original ES2 公式。
 */
#define BASE_WEIGHT 40000
#include <statistic.h>
#include <race.h>
inherit HUMANOID;

/* create／建立種族 Daemon：登記業值、文明種族旗標與種族識別。 */
private void create() {
    ::create(); seteuid(getuid()); set("karma", $k); set("civilized", 1);
    set("commoner_score_base", 100); DAEMON_D->register_race_daemon("$id");
}

/* setup／角色設定：套用種族物件並在沒有既有重量時提供 Runtime 測試基礎重量。 */
void setup(object ob) {
    ::setup(ob); ob->set_default_object(__FILE__);
    if (!ob->query_weight()) ob->set_weight(BASE_WEIGHT);
}

/* initialize／出生初始化：寫入八項天生屬性與精、氣、神初始值。 */
void initialize(object ob) {
    ::initialize(ob);
    /* Attribute／天生屬性：str臂力、cps膽識、int悟性、spi靈性、cor定力、dex機敏、con根骨、wis慧根。 */
    ob->init_attribute((["str":$value,"cps":$value,"int":$value,"spi":$value,"cor":$value,"dex":$value,"con":$value,"wis":$value]));
    /* Statistic／生命統計：gin精、kee氣、sen神，出生值各 30。 */
    ob->init_statistic((["gin":30,"kee":30,"sen":30]));
    if (!ob->query("age")) ob->set("age", 14 + random(4));
    ob->set_default_object(__FILE__);
}
LPC
}

for r in "${priority[@]}"; do write_race "$r" 50; done
for r in "${other[@]}"; do write_race "$r" 25; done

# Login registry／登入種族清單：加入歷史種族，同時保留既有 Original Human 與 Avatar。
python3 - "$LOGIN" <<'PY'
from pathlib import Path
import sys,re

# Python 只修改測試 Runtime 的 logind.c，不修改 Repository 中保存的 Original ES2 原始碼。
p=Path(sys.argv[1]); s=p.read_text()
races=['blackteeth','human','avatar','yenhold','woochan','dingling','jiaojao','rainnar','ashura','headless','yaksa','malik']
block='string *user_race = ({\n' + ''.join(f'    "{r}",\n' for r in races) + '});'
s,n=re.subn(r'string \*user_race = \(\{.*?\}\);',block,s,count=1,flags=re.S)
if n != 1:
    raise SystemExit('Could not replace user_race registry／無法更新登入種族清單')
p.write_text(s)
PY

echo 'M6-M9 RUNTIME OVERLAY PASS／執行環境覆蓋完成：新增 10 個歷史重建種族，保留 Original Human/Avatar；M6-M9=50，其餘重建種族=25。'
