#!/usr/bin/env bash
set -euo pipefail

# Static Regression／靜態回歸：只驗證保存下來的 Original ES2 師徒介面，不修改 Original 原始碼。
ROOT="${1:-.runtime/original-es2/mudlib}"
APP="$ROOT/cmds/std/apprentice.c"
REL="$ROOT/feature/char/relation.c"

fail() { echo "M14 APPRENTICE STATIC FAIL／失敗：$*" >&2; exit 1; }

test -f "$APP" || fail "找不到 Original apprentice.c"
test -f "$REL" || fail "找不到 Original relation.c"

# 玩家真正使用 apprentice <某人>，NPC 以 accept_apprentice() 決定是否收徒。
grep -Fq 'accept_apprentice(me)' "$APP" || fail "缺少 accept_apprentice 玩家拜師確認介面"
grep -Fq 'init_apprentice(me)' "$APP" || fail "缺少 init_apprentice 建立關係流程"
grep -Fq 'is_apprentice_of(ob)' "$APP" || fail "缺少重複拜師保護"

# Relation／關係資料：Original 以 masters/apprentices 兩個 mapping 建立雙向關係。
grep -Fq 'mapping masters = ([]);' "$REL" || fail "缺少 masters mapping"
grep -Fq 'mapping apprentices = ([]);' "$REL" || fail "缺少 apprentices mapping"
grep -Fq 'int add_master(object ob)' "$REL" || fail "缺少 add_master()"
grep -Fq 'int add_apprentice(object ob)' "$REL" || fail "缺少 add_apprentice()"
grep -Fq 'int init_apprentice(object ob) { return add_apprentice(ob); }' "$REL" || fail "缺少預設 init_apprentice()"

echo "M14 APPRENTICE STATIC PASS／通過：Original apprentice 指令與雙向師徒關係介面完整。"
