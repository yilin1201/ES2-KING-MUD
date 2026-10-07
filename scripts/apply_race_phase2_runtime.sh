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

# ES2M Score Progression／職業 target_score 與種族職業等級上限必須和 class daemon 同版。
# 若只更新 daemon/class 而保留 Original score.c，轉職/升級契約會不完整。
ES2M_SCORE="$REPO_ROOT/es2m_snapshot/mudlib/feature/char/score.c"
[[ -f "$ES2M_SCORE" ]] || { echo "Missing ES2M score progression: feature/char/score.c" >&2; exit 1; }
cp "$ES2M_SCORE" "$ROOT/mudlib/feature/char/score.c"

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

# ES2M Books／僅補入 Pinned Original 缺少的書籍；絕不覆蓋同名 Original。
ES2M_BOOK_DIR="$REPO_ROOT/es2m_snapshot/mudlib/obj/books"
if [[ -d "$ES2M_BOOK_DIR" ]]; then
  mkdir -p "$ROOT/mudlib/obj/books"
  for src in "$ES2M_BOOK_DIR"/*.c; do
    [[ -e "$src" ]] || continue
    dst="$ROOT/mudlib/obj/books/$(basename "$src")"
    if [[ ! -e "$dst" ]]; then cp "$src" "$dst"; fi
  done
fi

# ES2M Lee Village／李家村復原區：保留 ES2M provenance，不宣稱為 Original ES2。
ES2M_LEE_DIR="$REPO_ROOT/es2m_snapshot/mudlib/d/lee"
if [[ -d "$ES2M_LEE_DIR" ]]; then
  # Map Gate／地圖完整性：複製前核對已登錄房間與出口，避免將缺檔地圖導入正式 Runtime。
  # 尚未登錄的 ES2M 房間僅回報，不自動創造或改寫 Original Canon。
  python3 "$REPO_ROOT/scripts/test_es2m_lee_topology.py"
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

# ES2M Old Pine Forest／老松林完整區域導入：
# 僅在 Pinned Original 完全沒有 /d/oldpine 時建立新區域，避免覆蓋任何既有世界內容。
# 來源房間、NPC、物件與三個 NPC 裝備相依檔均先由 topology gate（拓樸閘門）驗證。
ES2M_OLDPINE_DIR="$REPO_ROOT/es2m_snapshot/mudlib/d/oldpine"
if [[ -d "$ES2M_OLDPINE_DIR" ]]; then
  python3 "$REPO_ROOT/scripts/test_es2m_oldpine_topology.py" \
    --source "$REPO_ROOT/es2m_snapshot/mudlib"

  if [[ -e "$ROOT/mudlib/d/oldpine" ]]; then
    # E2E 再次套用時僅允許逐檔一致的已導入區域，不得覆蓋差異。
    diff -qr "$ES2M_OLDPINE_DIR" "$ROOT/mudlib/d/oldpine" || {
      echo "ES2M OLDPINE CONFLICT: existing runtime differs from source" >&2; exit 1;
    }
    echo "ES2M OLDPINE IDEMPOTENT PASS"
  else
    mkdir -p "$ROOT/mudlib/d/oldpine"
    cp -a "$ES2M_OLDPINE_DIR/." "$ROOT/mudlib/d/oldpine/"
  fi

  # World connection／世界接線：ES2M entrance 的 northwest 已回到雪亭南門；
  # 只把 Pinned Original 原本註解且指向不存在 road1 的 southeast 改接 entrance。
  SNOW_SGATE="$ROOT/mudlib/d/snow/sgate.c"
  python3 - "$SNOW_SGATE" <<'PY'
from pathlib import Path
import sys

path = Path(sys.argv[1])
text = path.read_text()
old = '//\t"southeast" : "/d/oldpine/road1",'
new = '\t"southeast" : "/d/oldpine/entrance", // ES2M 老松林；只修改重建 Runtime。'
if new not in text:
    if old not in text:
        raise SystemExit("ES2M OLDPINE FAIL: Snow sgate oldpine marker changed")
    text = text.replace(old, new, 1)
path.write_text(text)
PY

  python3 "$REPO_ROOT/scripts/test_es2m_oldpine_topology.py" \
    --source "$REPO_ROOT/es2m_snapshot/mudlib" --runtime "$ROOT/mudlib"
  echo 'ES2M OLDPINE CONNECTED: 50 rooms, 17 NPCs and 5 local objects; Snow sgate southeast <-> entrance northwest.'
fi

# ES2M 振武軍營正式地圖接線：Owner 已授權開放軍營與原始徵兵規則。
# 僅修補重建 Runtime 的雪亭南門，不更動保存的 Original ES2 檔案。
# ES2M gate.c 的 east 原本已指向 /d/snow/sgate；此處恢復對向 west 出口。
SNOW_SGATE="$ROOT/mudlib/d/snow/sgate.c"
ZHENWU_GATE="$ROOT/mudlib/custom/zhenwu/room/gate.c"
ZHENWU_RECRUIT="$ROOT/mudlib/custom/zhenwu/obj/recruit_stone.c"
[[ -f "$SNOW_SGATE" && -f "$ZHENWU_GATE" && -f "$ZHENWU_RECRUIT" ]] || {
  echo "ES2M ZHENWU FAIL: missing Snow south gate or original camp/recruit sources" >&2; exit 1;
}
python3 "$REPO_ROOT/scripts/test_es2m_zhenwu_topology.py" "$ROOT/mudlib"
python3 - "$SNOW_SGATE" <<'PY'
from pathlib import Path
import sys
p=Path(sys.argv[1]); s=p.read_text()
old='//\t"west" : "/d/newcamp/gate",'
new='\t"west" : "/custom/zhenwu/room/gate", // ES2M 振武軍營；只修改重建 Runtime。'
if new not in s:
    if old not in s:
        raise SystemExit("ES2M ZHENWU FAIL: original Snow south gate west marker changed")
    s=s.replace(old,new,1)
p.write_text(s)
PY
python3 "$REPO_ROOT/scripts/test_es2m_zhenwu_recruitment.py" "$ROOT/mudlib"
echo 'ES2M ZHENWU CONNECTED: Snow sgate west <-> Zhenwu gate east; original enlist retained.'

# ES2M Wutang Town／五堂鎮（武當區域）完整導入：
# Pinned Original 沒有 /d/wutang；若其他工作已建立同名區域，立即停止並保留既有版本。
# 振武軍營大門的 south 出口直接沿用固定 ES2M 來源，不從 AI 推測世界連線。
ES2M_WUTANG_DIR="$REPO_ROOT/es2m_snapshot/mudlib/d/wutang"
if [[ -d "$ES2M_WUTANG_DIR" ]]; then
  python3 "$REPO_ROOT/scripts/test_es2m_wutang_topology.py" \
    --source "$REPO_ROOT/es2m_snapshot/mudlib"
  if [[ -e "$ROOT/mudlib/d/wutang" ]]; then
    diff -qr "$ES2M_WUTANG_DIR" "$ROOT/mudlib/d/wutang" || {
      echo "ES2M WUTANG CONFLICT: existing runtime differs from source" >&2; exit 1;
    }
    echo "ES2M WUTANG IDEMPOTENT PASS"
  else
    mkdir -p "$ROOT/mudlib/d/wutang"
    cp -a "$ES2M_WUTANG_DIR/." "$ROOT/mudlib/d/wutang/"
  fi
  python3 "$REPO_ROOT/scripts/test_es2m_wutang_topology.py" \
    --source "$REPO_ROOT/es2m_snapshot/mudlib" --runtime "$ROOT/mudlib"
  echo 'ES2M WUTANG CONNECTED: 56 rooms, 31 NPCs and 2 local objects; Zhenwu gate south <-> entrance north.'
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

# ES2M 657f682 gameplay delta／最新安全增量：留言板、當鋪、UTF-8 對齊與七彩石已讀紀錄。
# 這四檔不覆蓋 KING Combat／Save／Permission；vendor 另由 atomic shop adapter 管理，避免回退交易安全性。
for rel in adm/simul_efun/utf8.c std/bboard.c std/room/hockshop.c d/snow/obj/stone.c; do
  src="$REPO_ROOT/es2m_snapshot/mudlib/$rel"
  dst="$ROOT/mudlib/$rel"
  [[ -f "$src" && -f "$dst" ]] || { echo "ES2M 657f682 SAFE DELTA FAIL: $rel" >&2; exit 1; }
  cp "$src" "$dst"
done
echo 'ES2M 657f682 SAFE RUNTIME DELTA PASS／留言板、當鋪、UTF-8 對齊與七彩石已同步。'

# ES2M Weapon Affix Runtime Overlay／武器附加屬性 Runtime 覆蓋：
# 來源保留在獨立證據目錄，全部 SHA 與既有 Runtime 基準先驗證後才一次套用；
# 任何同路徑差異均停止，不覆蓋未知的 KING／其他工作成果。
python3 "$REPO_ROOT/scripts/apply_es2m_weapon_affix_runtime.py" \
  --runtime "$ROOT/mudlib"

# ES2M Shop Quantity／批量商店：只套用 buy、vendor、waiter 三個已鎖定檔案。
# KING 整合版保留店小二延遲送菜，並把扣款延後到完整交貨成功之後。
python3 "$REPO_ROOT/scripts/apply_es2m_shop_quantity_runtime.py" \
  --runtime "$ROOT/mudlib"

# ES2M Container Runtime／容器修復：讓複製出的容器繼承原型單位、價值與說明，
# 並同步最新 10 公升牛皮水袋；來源與目標都先經 SHA 閘門驗證。
python3 "$REPO_ROOT/scripts/apply_es2m_container_runtime.py" \
  --runtime "$ROOT/mudlib"

# Combined Item Persistence／組合物品保存：商店購買的包子、饅頭等數量在 save/quit/relogin 後保留。
# 不修改玩家 save format；沿用既有 user autoload 陣列，只補 COMBINED_ITEM 的既有 autoload 契約。
python3 "$REPO_ROOT/scripts/apply_combined_item_autoload_runtime.py" \
  --runtime "$ROOT/mudlib"

# Shop Item Persistence／非堆疊商店商品：沿用 user autoload，保存毛皮帽與牛皮水袋物件。
python3 "$REPO_ROOT/scripts/apply_shop_item_autoload_runtime.py" \
  --runtime "$ROOT/mudlib"

echo 'ES2M RACE RUNTIME OVERLAY PASS／10 個缺失種族改由 ES2M daemon 恢復；保留 Original Human/Avatar；登入流程接受 12 種族。'

