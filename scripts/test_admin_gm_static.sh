#!/usr/bin/env bash
set -euo pipefail

# ADMIN GM Static Gate／管理員指令靜態閘門：確認來源、權限、命令索引與關鍵安全條件。
ROOT="es2_king_expansion/runtime/mudlib"
COMMAND="$ROOT/cmds/adm/admin.c"
TIGER_BLADE="$ROOT/custom/weapon/blade/tiger_blade.c"
APPLY="scripts/apply_es2_king_expansion.sh"

test -f "$COMMAND" || { echo "ADMIN GM STATIC FAIL：缺少 Expansion 指令檔 $COMMAND" >&2; exit 1; }
test -f "$TIGER_BLADE" || { echo "ADMIN GM STATIC FAIL：缺少 admin setup 依賴的虎紋刀 Expansion 物件。" >&2; exit 1; }
grep -Fq 'inherit F_UNIQUE;' "$TIGER_BLADE"
grep -Fq 'inherit F_BLADE;' "$TIGER_BLADE"
test -f "$APPLY" || { echo "ADMIN GM STATIC FAIL：缺少 Runtime 套用腳本" >&2; exit 1; }

# 來源與分層：此檔是 ES2-KING Expansion 參考整合，不冒稱 Original ES2。
grep -Fq 'ES2-KING Expansion／管理員 GM 指令整合層' "$COMMAND"
grep -Fq '463259b74a897c28c199682caa5af21074bf69b1' "$COMMAND"

# 權限與直接呼叫檢查：一般玩家不能執行管理員命令。
grep -Fq 'previous_object() != me' "$COMMAND"
grep -Fq 'this_player(1) != me' "$COMMAND"
grep -Fq 'wiz_level(me) < wiz_level("(admin)")' "$COMMAND"

# 目標安全／只能操作在線玩家，且不能藉由 GM 指令修改其他最高管理員。
grep -Fq '!interactive(ob)' "$COMMAND"
if grep -Fq 'ob = find_living(name);' "$COMMAND"; then
  echo 'ADMIN GM STATIC FAIL：目標查找仍允許 NPC 或非玩家物件。' >&2
  exit 1
fi
grep -Fq 'private object mutable_target' "$COMMAND"
grep -Fq 'wiz_level(ob) >= wiz_level("(admin)")' "$COMMAND"
test "$(grep -Ec 'ob = mutable_target\(me, (target_name|target)\);' "$COMMAND")" -ge 13

# 指令語意／技能用途映射、狀態驗證及武器名稱相容。
grep -Fq 'ob->map_skill(cmd, skill);' "$COMMAND"
grep -Fq 'query_stat_effective(stat)' "$COMMAND"
grep -Fq 'present(replace_string(cmd, "_", " "), ob)' "$COMMAND"

# 數值與物件處理：拒絕負值，HP 不超過最大值，物件路徑需先確認存在。
grep -Fq 'ATTRVAL_MIN' "$COMMAND"
grep -Fq 'ATTRVAL_MAX' "$COMMAND"
grep -Fq 'ADMIN_SKILL_MAX 200' "$COMMAND"
grep -Fq 'ADMIN_LEVEL_MAX 999' "$COMMAND"
# ES2-KING Help／正式八大屬性對照；防止 Help 文案與 KING 設定再次錯置。
grep -Fq 'ES2-KING ADMIN GM 使用教學（King 管理角色）' "$COMMAND"
grep -Fq 'admin str <數值> [玩家]       膂力（原版範圍 1～50）' "$COMMAND"
grep -Fq 'admin cor <數值> [玩家]       膽識（原版範圍 1～50）' "$COMMAND"
grep -Fq 'admin int <數值> [玩家]       悟性（原版範圍 1～50）' "$COMMAND"
grep -Fq 'admin spi <數值> [玩家]       靈性（原版範圍 1～50）' "$COMMAND"
grep -Fq 'admin cps <數值> [玩家]       定力（原版範圍 1～50）' "$COMMAND"
grep -Fq 'admin dex <數值> [玩家]       機敏（原版範圍 1～50）' "$COMMAND"
grep -Fq 'admin con <數值> [玩家]       根骨（原版範圍 1～50）' "$COMMAND"
grep -Fq 'admin wis <數值> [玩家]' "$COMMAND"
grep -Fq '慧根（原版範圍 1～50）' "$COMMAND"
grep -Fq '【King 管理角色操作範例】' "$COMMAND"
grep -Fq 'if (value < 0)' "$COMMAND"
grep -Fq 'query_stat_maximum("HP")' "$COMMAND"
grep -Fq 'object_file(value_s)' "$COMMAND"
# 生成物件與移動分開驗證；移動失敗必須清除新物件。
grep -Fq 'if (!gift->move(ob))' "$COMMAND"
grep -Fq 'if (!gift->move(me))' "$COMMAND"
grep -Fq 'if (!gift->move(ob))' "$COMMAND"
grep -Fq 'if (!gift->move(me))' "$COMMAND"
grep -Fq '先預檢虎紋刀來源' "$COMMAND"
grep -Fq '!weapon->wield()' "$COMMAND"

# ES2-KDS admin improvements／技能名稱可含空格，學習與等級修改都必須解析並回讀驗證。
grep -Fq 'private string resolve_skill_name(string name)' "$COMMAND"
grep -Fq 'replace_string(name, " ", "_")' "$COMMAND"
grep -Fq 'if (!(int)ob->query_learn(resolved)' "$COMMAND"
# 管理員技能設定回讀驗證：value 是實際讀回值，skill_level 是要求值；兩者不等必須拒絕。
grep -Fq 'value = (int)ob->query_skill(resolved, 1);' "$COMMAND"
grep -Fq 'value = (int)me->query_skill(resolved, 1);' "$COMMAND"
grep -Fq 'if (value != skill_level)' "$COMMAND"

# ES2-KDS soldier level-up fix／Expansion 必須保存軍人升級 daemon，原始來源不直接覆寫。
SOLDIER="$ROOT/daemon/class/soldier.c"
test -f "$SOLDIER" || { echo "ADMIN GM STATIC FAIL：缺少軍人升級修正 $SOLDIER" >&2; exit 1; }
grep -Fq 'static void create() { seteuid(getuid()); }' "$SOLDIER"
grep -Fq 'set_next_target(ob, ob->query_level() + 1);' "$SOLDIER"

# 載入整合：Runtime 重新索引與預載清單都必須包含 admin。
grep -Fq 'member_array(verb, ({ "admin", "kingcreate"' "$APPLY"
grep -Fq 'for owner_command in admin kingcreate' "$APPLY"

# 反回歸：不允許錯誤的雙重跳脫換行字串殘留。
if grep -Fq '\\n' "$COMMAND"; then
  echo 'ADMIN GM STATIC FAIL：發現多重跳脫的換行字串。' >&2
  exit 1
fi



# Unlearn regression／取消學習須清理用途映射，不可把技能錯誤標記為 disabled。
grep -Fq 'private void unlearn_skill(object ob, string skill)' "$COMMAND"
grep -Fq 'unlearn_skill(ob, resolved);' "$COMMAND"
grep -Fq 'unlearn_skill(me, resolved);' "$COMMAND"
if grep -Fq 'map_skill(skill, "none")' "$COMMAND"; then
  echo 'ADMIN GM STATIC FAIL：unlearn 將技能設為 disabled，而非清理用途映射。' >&2
  exit 1
fi

# Skill mapping regression／用途對應必須以「用途、技能」順序呼叫 Original map_skill。
grep -Fq 'ob->map_skill(cmd, skill)' "$COMMAND"
grep -Fq 'me->map_skill(cmd, skill)' "$COMMAND"
if grep -Fq 'map_skill(skill, skill)' "$COMMAND"; then
  echo 'ADMIN GM STATIC FAIL：用途對應錯把技能名稱當成用途。' >&2
  exit 1
fi
grep -Fq 'ob->map_skill(skill);' "$COMMAND"
grep -Fq 'foreach (usage, mapped in skill_map)' "$COMMAND"
grep -Fq 'if (mapped == skill)' "$COMMAND"

echo 'ADMIN GM STATIC PASS／Expansion 路徑、管理員權限、數值保護與技能解除映射檢查通過。'
