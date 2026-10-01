#!/usr/bin/env bash
set -euo pipefail

# Runtime overlay／執行環境覆蓋層：只在測試用 Runtime 產生歷史種族，不改寫保存的 Original ES2 原始證據。
ROOT="${1:-.runtime/original-es2}"
RACE_DIR="$ROOT/mudlib/daemon/race"
LOGIN="$ROOT/mudlib/adm/daemons/logind.c"

# Bootstrap／建立執行環境：必須先由 bootstrap_original_es2.sh 準備好 Original ES2 Runtime。
[[ -d "$RACE_DIR" && -f "$LOGIN" ]] || { echo "Race runtime not bootstrapped／種族執行環境尚未建立" >&2; exit 1; }

# ES2M Recovery／ES2M 種族恢復
# Evidence priority: Original ES2 > ES2M > Archived/Historical > Reconstruction.
# Human/avatar retain the existing Original runtime daemons.
# Ten missing races are restored from the vendored ES2M snapshot instead of fabricated fixed attributes.
REPO_ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
ES2M_RACE_DIR="$REPO_ROOT/es2m_snapshot/mudlib/daemon/race"
es2m_races=(blackteeth yenhold woochan dingling jiaojao rainner ashura headless yaksa malik)
[[ -d "$ES2M_RACE_DIR" ]] || { echo "ES2M race snapshot missing: $ES2M_RACE_DIR" >&2; exit 1; }
for race in "${es2m_races[@]}"; do
  [[ -f "$ES2M_RACE_DIR/$race.c" ]] || { echo "Missing ES2M race daemon: $race" >&2; exit 1; }
  cp "$ES2M_RACE_DIR/$race.c" "$RACE_DIR/$race.c"
  if [[ -d "$ES2M_RACE_DIR/$race" ]]; then
    mkdir -p "$RACE_DIR/$race"
    cp -a "$ES2M_RACE_DIR/$race/." "$RACE_DIR/$race/"
  fi
done

# ES2M Race Commands／種族專屬玩家指令：
# Original 玩家 PLR_PATH 只搜尋 /cmds/std 與 /cmds/usr；daemon/race/<race>/ 下的能力檔不會自動成為玩家指令。
# 以原 ES2M command 檔本身作為唯一行為來源，只做可達性接線，不改寫能力公式。
declare -A race_commands=(
  [blackteeth]=gnaw [yenhold]=breathe [woochan]=replete [dingling]=hoof
  [jiaojao]=hide [rainner]=feed [headless]=dance [yaksa]=devour
)
mkdir -p "$ROOT/mudlib/cmds/usr"
for race in "${!race_commands[@]}"; do
  cmd="${race_commands[$race]}"
  src="$ES2M_RACE_DIR/$race/$cmd.c"
  [[ -f "$src" ]] || { echo "Missing ES2M race command: $race/$cmd" >&2; exit 1; }
  cp "$src" "$ROOT/mudlib/cmds/usr/$cmd.c"
done

# Optional ES2M custom race support (conditions/objects) is copied only when vendored.
ES2M_CUSTOM_DIR="$REPO_ROOT/es2m_snapshot/mudlib/custom/race"
if [[ -d "$ES2M_CUSTOM_DIR" ]]; then
  mkdir -p "$ROOT/mudlib/custom/race"
  cp -a "$ES2M_CUSTOM_DIR/." "$ROOT/mudlib/custom/race/"
fi

# ES2M Class progression／ES2M 職業成長程式
ES2M_CLASS_DIR="$REPO_ROOT/es2m_snapshot/mudlib/daemon/class"
if [[ -d "$ES2M_CLASS_DIR" ]]; then
  mkdir -p "$ROOT/mudlib/daemon/class"
  for cls in commoner fighter taoist alchemist soldier scholar monk thief; do
    [[ -f "$ES2M_CLASS_DIR/$cls.c" ]] || { echo "Missing ES2M class daemon: $cls" >&2; exit 1; }
    cp "$ES2M_CLASS_DIR/$cls.c" "$ROOT/mudlib/daemon/class/$cls.c"
  done
fi
if [[ -f "$REPO_ROOT/es2m_snapshot/mudlib/include/class_level.h" ]]; then
  cp "$REPO_ROOT/es2m_snapshot/mudlib/include/class_level.h" "$ROOT/mudlib/include/class_level.h"
fi

# ES2M Skill Recovery／只補 pinned Original 不存在的 ES2M skill daemon；Original 同名技能永不覆蓋。
ES2M_SKILL_DIR="$REPO_ROOT/es2m_snapshot/mudlib/daemon/skill"
if [[ -d "$ES2M_SKILL_DIR" ]]; then
  mkdir -p "$ROOT/mudlib/daemon/skill"
  for src in "$ES2M_SKILL_DIR"/*.c; do
    [[ -e "$src" ]] || continue
    name="$(basename "$src")"
    if [[ ! -e "$ROOT/mudlib/daemon/skill/$name" ]]; then
      cp "$src" "$ROOT/mudlib/daemon/skill/$name"
    fi
  done
fi

# ES2M Equipment Library／朋友武器資料：只覆蓋 custom namespace，不取代 Pinned Original world files。
ES2M_CUSTOM_DIR="$REPO_ROOT/es2m_snapshot/mudlib/custom"
if [[ -d "$ES2M_CUSTOM_DIR" ]]; then
  mkdir -p "$ROOT/mudlib/custom"
  cp -a "$ES2M_CUSTOM_DIR/." "$ROOT/mudlib/custom/"
  echo 'ES2M CUSTOM EQUIPMENT RUNTIME IMPORT PASS／ES2M custom 武器裝備資料已匯入獨立 Runtime。'
fi

# ES2M Lee Village／李家村復原區：保留 ES2M provenance，不宣稱為 Original ES2。
ES2M_LEE_DIR="$REPO_ROOT/es2m_snapshot/mudlib/d/lee"
if [[ -d "$ES2M_LEE_DIR" ]]; then
  mkdir -p "$ROOT/mudlib/d/lee"
  cp -a "$ES2M_LEE_DIR/." "$ROOT/mudlib/d/lee/"

  # World connection／只修改重建 Runtime 的雪亭東門，不修改 Repository 保存的 Original source。
  SNOW_EGATE="$ROOT/mudlib/d/snow/egate.c"
  python3 - "$SNOW_EGATE" <<'PY'
from pathlib import Path
import sys
p=Path(sys.argv[1]); s=p.read_text()
if '"northeast" : "/d/lee/entrance_s"' not in s:
    marker='set("exits", (['
    i=s.find(marker)
    if i < 0: raise SystemExit('Could not locate Snow egate exits')
    j=s.find(']));', i)
    if j < 0: raise SystemExit('Could not close Snow egate exits')
    s=s[:j]+'        "northeast" : "/d/lee/entrance_s",\n'+s[j:]
p.write_text(s)
PY
  echo 'ES2M LEE VILLAGE RUNTIME IMPORT PASS／李家村復原區已接入雪亭東門 northeast。'
fi

# Race Command Collision／種族指令同名衝突：Original EMOTED 也註冊 dance 表情。
# 只在刑天本人輸入 dance 時優先走 ES2M /cmds/usr/dance；其他玩家仍保留 Original 通用 dance。
COMMAND_D="$ROOT/mudlib/adm/daemons/cmd_d.c"
python3 - "$COMMAND_D" <<'PY'
from pathlib import Path
import sys
p=Path(sys.argv[1]); s=p.read_text()
marker='''    if( !pointerp(path) ) return 0;\n\n'''
patch='''    if( !pointerp(path) ) return 0;\n\n    // ES2M HEADLESS DANCE COMMAND ROUTING／刑天 dance 優先使用種族戰舞；其他種族保留 Original 表情。\n    if( verb == "dance" && objectp(this_player())\n    &&  this_player()->query_race() == "headless"\n    &&  file_size("/cmds/usr/dance.c") > 0 )\n        return "/cmds/usr/dance";\n\n'''
if 'ES2M HEADLESS DANCE COMMAND ROUTING' not in s:
    if marker not in s: raise SystemExit('Could not locate COMMAND_D find_command path guard')
    s=s.replace(marker,patch,1)
p.write_text(s)
PY

# Login registry／登入種族清單：加入歷史種族，同時保留既有 Original Human 與 Avatar。
python3 - "$LOGIN" <<'PY'
from pathlib import Path
import sys,re

# Python 只修改測試 Runtime 的 logind.c，不修改 Repository 中保存的 Original ES2 原始碼。
p=Path(sys.argv[1]); s=p.read_text()
races=['blackteeth','human','avatar','yenhold','woochan','dingling','jiaojao','rainner','ashura','headless','yaksa','malik']
block='string *user_race = ({\n' + ''.join(f'    "{r}",\n' for r in races) + '});'
s,n=re.subn(r'string \*user_race = \(\{.*?\}\);',block,s,count=1,flags=re.S)
if n != 1:
    raise SystemExit('Could not replace user_race registry／無法更新登入種族清單')

# Race acceptance／種族接受邏輯：目前保存的 Original logind.c 的 get_race() 只接受 human/avatar。
# 重建 Runtime 必須同步讓歷史種族通過 switch，否則游標雖可選到種族，確認後仍會被退回選單。
marker='''        case "avatar":\n            race = "avatar";\n            break;'''
extra=''.join(f'''\n        case "{race}":\n            race = "{race}";\n            break;''' for race in races if race not in ('human','avatar'))
if marker not in s:
    raise SystemExit('Could not locate get_race switch／找不到登入種族接受邏輯')
s=s.replace(marker, marker+extra, 1)
p.write_text(s)
PY

echo 'ES2M RACE RUNTIME OVERLAY PASS／10 個缺失種族改由 ES2M daemon 恢復；保留 Original Human/Avatar；登入流程接受 12 種族。'
