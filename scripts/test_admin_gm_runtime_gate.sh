#!/usr/bin/env bash
set -euo pipefail

# ADMIN GM Runtime Gate／生成 Runtime 閘門：確認 Expansion 已複製到 Neolith 實際 mudlib。
ROOT="${1:-.runtime/es2-king}/mudlib"
COMMAND="$ROOT/cmds/adm/admin.c"
TIGER_BLADE="$ROOT/custom/weapon/blade/tiger_blade.c"
SOLDIER="$ROOT/daemon/class/soldier.c"
COMMAND_D="$ROOT/adm/daemons/cmd_d.lpc"
PRELOAD="$ROOT/adm/etc/preload"

for file in "$COMMAND" "$COMMAND_D" "$PRELOAD" "$TIGER_BLADE" "$SOLDIER"; do
  test -f "$file" || { echo "ADMIN GM RUNTIME FAIL：缺少 $file" >&2; exit 1; }
done

grep -Fq 'ES2-KING Expansion／管理員 GM 指令整合層' "$COMMAND"
grep -Fq 'wiz_level(me) < wiz_level("(admin)")' "$COMMAND"
grep -Fq 'ATTRVAL_MAX' "$COMMAND"
grep -Fq 'ADMIN_SKILL_MAX 200' "$COMMAND"
grep -Fq 'ADMIN_LEVEL_MAX 999' "$COMMAND"
grep -Fq 'ES2-KING OWNER COMMAND REHASH' "$COMMAND_D"
grep -Fq '"admin", "kingcreate"' "$COMMAND_D"
grep -Fqx '/cmds/adm/admin' "$PRELOAD"

# ES2-KDS admin improvements／生成 Runtime 必須包含技能名稱解析與修改回讀驗證。
grep -Fq 'private string resolve_skill_name(string name)' "$COMMAND"
grep -Fq 'if (!(int)ob->query_learn(resolved)' "$COMMAND"
grep -Fq 'if (value != level)' "$COMMAND"

# ES2-KDS soldier fix／確認軍人職業實際套用修正後的升級 daemon。
grep -Fq 'static void create() { seteuid(getuid()); }' "$SOLDIER"
grep -Fq 'void set_next_target(object ob, int cur_lv)' "$SOLDIER"
grep -Fq 'ob->set_target_score("military service"' "$SOLDIER"

# 檢查權限不足時明確回覆，避免管理員指令無聲失敗。
grep -Fq 'ADMIN: 你沒有管理員權限。' "$COMMAND"

# Runtime overlay 也必須保留目標安全與狀態驗證，避免只修 source 未修生成檔。
grep -Fq '!interactive(ob)' "$COMMAND"
if grep -Fq 'ob = find_living(name);' "$COMMAND"; then
  echo 'ADMIN GM RUNTIME FAIL：生成 Runtime 仍可將 NPC 當作玩家目標。' >&2
  exit 1
fi
grep -Fq 'private object mutable_target' "$COMMAND"
grep -Fq 'wiz_level(ob) >= wiz_level("(admin)")' "$COMMAND"
test "$(grep -Fc 'ob = mutable_target(me, target_name);' "$COMMAND")" -ge 16
grep -Fq 'ob->map_skill(cmd, skill);' "$COMMAND"
grep -Fq 'query_stat_effective(stat)' "$COMMAND"
grep -Fq 'present(replace_string(cmd, "_", " "), ob)' "$COMMAND"
# 物件失敗清理與 setup 裝備回報／生成 Runtime 必須與 Expansion 原始檔一致。
grep -Fq 'if (!gift->move(ob))' "$COMMAND"
grep -Fq 'if (!gift->move(me))' "$COMMAND"
grep -Fq '先預檢虎紋刀來源' "$COMMAND"
grep -Fq '!weapon->wield()' "$COMMAND"



# Unlearn regression／實際生成 Runtime 必須採用同一個安全映射清理 helper。
grep -Fq 'private void unlearn_skill(object ob, string skill)' "$COMMAND"
grep -Fq 'unlearn_skill(ob, skill);' "$COMMAND"
grep -Fq 'unlearn_skill(me, skill);' "$COMMAND"
if grep -Fq 'map_skill(skill, "none")' "$COMMAND"; then
  echo 'ADMIN GM RUNTIME FAIL：unlearn 將技能錯誤設為 disabled。' >&2
  exit 1
fi

# Skill mapping regression／生成 Runtime 不可將技能映射寫反。
grep -Fq 'ob->map_skill(cmd, skill)' "$COMMAND"
grep -Fq 'me->map_skill(cmd, skill)' "$COMMAND"
if grep -Fq 'map_skill(skill, skill)' "$COMMAND"; then
  echo 'ADMIN GM RUNTIME FAIL：技能用途對應寫反。' >&2
  exit 1
fi
grep -Fq 'ob->map_skill(skill);' "$COMMAND"
grep -Fq 'foreach (usage, mapped in skill_map)' "$COMMAND"
grep -Fq 'if (mapped == skill)' "$COMMAND"

echo 'ADMIN GM RUNTIME GATE PASS／生成 Runtime 已包含 admin.c、命令索引、預載與技能解除映射檢查。'
