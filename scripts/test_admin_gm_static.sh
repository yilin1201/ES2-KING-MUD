#!/usr/bin/env bash
set -euo pipefail

# ADMIN GM Static Gate／管理員指令靜態閘門：確認來源、權限、命令索引與關鍵安全條件。
ROOT="es2_king_expansion/runtime/mudlib"
COMMAND="$ROOT/cmds/adm/admin.c"
APPLY="scripts/apply_es2_king_expansion.sh"

test -f "$COMMAND" || { echo "ADMIN GM STATIC FAIL：缺少 Expansion 指令檔 $COMMAND" >&2; exit 1; }
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
test "$(grep -Fc 'ob = mutable_target(me, target_name);' "$COMMAND")" -ge 14

# 指令語意／技能用途映射、狀態驗證及武器名稱相容。
grep -Fq 'ob->map_skill(cmd, skill);' "$COMMAND"
grep -Fq 'query_stat_effective(stat)' "$COMMAND"
grep -Fq 'present(replace_string(cmd, "_", " "), ob)' "$COMMAND"

# 數值與物件處理：拒絕負值，HP 不超過最大值，物件路徑需先確認存在。
grep -Fq 'ATTRVAL_MIN' "$COMMAND"
grep -Fq 'ATTRVAL_MAX' "$COMMAND"
grep -Fq 'ADMIN_SKILL_MAX 200' "$COMMAND"
grep -Fq 'ADMIN_LEVEL_MAX 999' "$COMMAND"
grep -Fq '膂力（原版 1～50）' "$COMMAND"
grep -Fq '慧根（原版 1～50）' "$COMMAND"
grep -Fq 'if (value < 0)' "$COMMAND"
grep -Fq 'query_stat_maximum("HP")' "$COMMAND"
grep -Fq 'object_file(value_s)' "$COMMAND"
grep -Fq 'if (!objectp(gift) || !gift->move' "$COMMAND"

# 載入整合：Runtime 重新索引與預載清單都必須包含 admin。
grep -Fq 'member_array(verb, ({ "admin", "kingcreate"' "$APPLY"
grep -Fq 'for owner_command in admin kingcreate' "$APPLY"

# 反回歸：不允許錯誤的雙重跳脫換行字串殘留。
if grep -Fq '\\n' "$COMMAND"; then
  echo 'ADMIN GM STATIC FAIL：發現多重跳脫的換行字串。' >&2
  exit 1
fi

echo 'ADMIN GM STATIC PASS／Expansion 路徑、管理員權限、數值保護與載入設定檢查通過。'
